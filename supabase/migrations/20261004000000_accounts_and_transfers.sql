-- Accounts and transfers.
--
--   accounts   where money is held (bank, e-wallet, cash)
--   transfers  money moved from one account to another. A transfer is NOT a
--              transaction: it is never income or expense. Its optional fee is
--              stored on the transfer and also written by the app as a normal
--              expense transaction (category Fees, transfer_id set), so every
--              report, budget and alert counts the fee without knowing about
--              transfers.
--
-- transactions gains account_id (null = the user's default Cash account, which
-- the app creates with a fixed per-user id) and transfer_id (no foreign key:
-- the app pushes transfers before transactions, but a plain uuid keeps a late
-- or failed push from blocking everything else).
--
-- DEPLOY ORDER: run this BEFORE shipping the app version that uses it. That
-- app sends account_id / transfer_id on every transaction, and the columns
-- must exist. Older app builds are unaffected (the columns are nullable and
-- an upsert that omits them leaves them as they are).
--
-- Idempotent: safe to run more than once.

create table if not exists public.accounts (
  id               uuid primary key,
  user_id          uuid not null references auth.users(id) on delete cascade,
  name             text not null check (char_length(btrim(name)) > 0),
  type             text not null check (type in ('bank', 'ewallet', 'cash')),
  opening_balance  numeric(18,2) not null default 0,
  is_archived      boolean not null default false,
  is_deleted       boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists accounts_user_updated_idx
  on public.accounts (user_id, updated_at);

create table if not exists public.transfers (
  id               uuid primary key,
  user_id          uuid not null references auth.users(id) on delete cascade,
  from_account_id  uuid not null references public.accounts(id),
  to_account_id    uuid not null references public.accounts(id),
  amount           numeric(18,2) not null check (amount > 0),
  fee              numeric(18,2) not null default 0 check (fee >= 0),
  note             text,
  date             timestamptz not null,
  is_deleted       boolean not null default false,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now(),
  check (from_account_id <> to_account_id)
);

create index if not exists transfers_user_updated_idx
  on public.transfers (user_id, updated_at);
create index if not exists transfers_user_date_idx
  on public.transfers (user_id, date desc);

alter table public.transactions
  add column if not exists account_id uuid references public.accounts(id),
  add column if not exists transfer_id uuid;

create index if not exists transactions_account_idx
  on public.transactions (account_id);

-- Row level security: each user sees and changes only their own rows.
alter table public.accounts enable row level security;
alter table public.transfers enable row level security;

drop policy if exists accounts_select_own on public.accounts;
create policy accounts_select_own on public.accounts
  for select using (auth.uid() = user_id);
drop policy if exists accounts_insert_own on public.accounts;
create policy accounts_insert_own on public.accounts
  for insert with check (auth.uid() = user_id);
drop policy if exists accounts_update_own on public.accounts;
create policy accounts_update_own on public.accounts
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists accounts_delete_own on public.accounts;
create policy accounts_delete_own on public.accounts
  for delete using (auth.uid() = user_id);

drop policy if exists transfers_select_own on public.transfers;
create policy transfers_select_own on public.transfers
  for select using (auth.uid() = user_id);
drop policy if exists transfers_insert_own on public.transfers;
create policy transfers_insert_own on public.transfers
  for insert with check (auth.uid() = user_id);
drop policy if exists transfers_update_own on public.transfers;
create policy transfers_update_own on public.transfers
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists transfers_delete_own on public.transfers;
create policy transfers_delete_own on public.transfers
  for delete using (auth.uid() = user_id);

drop trigger if exists accounts_touch_updated_at on public.accounts;
create trigger accounts_touch_updated_at
  before update on public.accounts
  for each row execute function public.touch_updated_at();

drop trigger if exists transfers_touch_updated_at on public.transfers;
create trigger transfers_touch_updated_at
  before update on public.transfers
  for each row execute function public.touch_updated_at();

-- The default category that holds transfer fees. The id must match
-- DefaultCategories.feesId in the app.
insert into public.categories (id, name, icon, type) values
  ('00000000-0000-4000-8000-000000000013', 'Fees', 'payments', 'expense')
on conflict (id) do nothing;

-- evaluate_alerts(): Rule A (category_spike) now ignores transfer fees, so a
-- run of small bank fees cannot raise a "Fees spending is up" alert. Every other
-- rule is copied unchanged from 20261003000100_budget_and_positive_alerts.sql
-- (CREATE OR REPLACE FUNCTION has to restate the whole body). Transfer fees
-- still count as spending in the overspend and budget rules, on purpose.

create or replace function public.evaluate_alerts()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_period text := to_char(date_trunc('month', now()), 'YYYY-MM');
  v_month_start timestamptz := date_trunc('month', now());
  v_prev_month_start timestamptz := date_trunc('month', now()) - interval '1 month';
  v_threshold numeric := 1.25;   -- category spend > 125% of previous period
  v_pace_ratio numeric := 0.75;  -- wishlist behind 75% of linear-pace expectation
  v_budget_warn numeric := 0.85; -- category at 85% of its monthly limit
  v_min_timeline numeric := 0.25; -- goal_on_track waits until a quarter of the way to the deadline
  v_inserted integer := 0;
  v_count integer;
begin

  -- Rule A: category_spike — this month's category expense > 1.25x last month's
  with cur_month as (
    select user_id, category_id, sum(amount) as total
    from transactions
    where type = 'expense' and is_deleted = false and transfer_id is null
      and date >= v_month_start
    group by user_id, category_id
  ),
  prev_month as (
    select user_id, category_id, sum(amount) as total
    from transactions
    where type = 'expense' and is_deleted = false and transfer_id is null
      and date >= v_prev_month_start and date < v_month_start
    group by user_id, category_id
  )
  insert into alerts (user_id, type, category_id, period, message, metadata)
  select
    cur.user_id,
    'category_spike',
    cur.category_id,
    v_period,
    format(
      '%s spending is up %s%% this month — %s vs %s last month.',
      c.name,
      round(((cur.total - prev.total) / prev.total) * 100),
      cur.total,
      prev.total
    ),
    jsonb_build_object(
      'current_amount', cur.total,
      'previous_amount', prev.total,
      'percent_change', round(((cur.total - prev.total) / prev.total) * 100, 1)
    )
  from cur_month cur
  join prev_month prev on prev.user_id = cur.user_id and prev.category_id = cur.category_id
  join categories c on c.id = cur.category_id
  where prev.total > 0
    and cur.total > prev.total * v_threshold
    and not exists (
      select 1 from alerts a
      where a.user_id = cur.user_id and a.type = 'category_spike'
        and a.category_id = cur.category_id and a.period = v_period
    )
  on conflict (user_id, type, category_id, period) do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  -- Rule B: overspend — this month's total expense > total income
  with monthly_totals as (
    select
      user_id,
      coalesce(sum(amount) filter (where type = 'income'), 0) as income,
      coalesce(sum(amount) filter (where type = 'expense'), 0) as expense
    from transactions
    where is_deleted = false and date >= v_month_start
    group by user_id
  )
  insert into alerts (user_id, type, category_id, period, message, metadata)
  select
    t.user_id,
    'overspend',
    null,
    v_period,
    format(
      'You''ve spent %s more than you''ve earned this month (%s income vs %s expenses).',
      t.expense - t.income, t.income, t.expense
    ),
    jsonb_build_object(
      'current_amount', t.expense,
      'previous_amount', t.income,
      'percent_change', case when t.income > 0
        then round(((t.expense - t.income) / t.income) * 100, 1) else null end
    )
  from monthly_totals t
  where t.expense > t.income
    and not exists (
      select 1 from alerts a
      where a.user_id = t.user_id and a.type = 'overspend'
        and a.category_id is null and a.period = v_period
    )
  on conflict (user_id, type, category_id, period) do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  -- Rule C: wishlist_off_pace — actual savings behind linear-pace expectation
  -- for the goal's deadline. Only evaluated for active, non-expired goals
  -- that have a deadline (pacing is undefined without one).
  with paced as (
    select
      w.*,
      least(
        greatest(
          extract(epoch from (now() - w.created_at))
            / nullif(extract(epoch from (w.deadline - w.created_at)), 0),
          0
        ),
        1
      ) as expected_fraction
    from wishlist w
    where w.is_deleted = false
      and w.deadline is not null
      and w.deadline > now()
      and w.current_amount < w.target_amount
  )
  insert into alerts (user_id, type, category_id, period, message, metadata)
  select
    p.user_id,
    'wishlist_off_pace',
    null,
    v_period,
    format(
      '"%s" is behind pace — you''re at %s%% but should be around %s%% by now.',
      p.name,
      round((p.current_amount / p.target_amount) * 100),
      round(p.expected_fraction * 100)
    ),
    jsonb_build_object(
      'goal_id', p.id,
      'current_amount', p.current_amount,
      'previous_amount', round(p.target_amount * p.expected_fraction, 2),
      'percent_change', round(
        ((p.current_amount - (p.target_amount * p.expected_fraction))
          / nullif(p.target_amount * p.expected_fraction, 0)) * 100, 1)
    )
  from paced p
  where p.expected_fraction > 0
    and p.current_amount < (p.target_amount * p.expected_fraction * v_pace_ratio)
    and not exists (
      select 1 from alerts a
      where a.user_id = p.user_id and a.type = 'wishlist_off_pace'
        and a.period = v_period and a.metadata->>'goal_id' = p.id::text
    );
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  -- Rule D: budget_limit — a category with a monthly limit has used 85% or
  -- more of it this month. Fires once per category per month, at that first
  -- crossing; the message says so plainly if the limit itself is already hit.
  with spend as (
    select user_id, category_id, sum(amount) as total
    from transactions
    where type = 'expense' and is_deleted = false and date >= v_month_start
    group by user_id, category_id
  )
  insert into alerts (user_id, type, category_id, period, message, metadata)
  select
    b.user_id,
    'budget_limit',
    b.category_id,
    v_period,
    case
      when s.total >= b.monthly_limit then
        format('%s has reached its monthly limit of %s — %s spent.',
               c.name, public.format_idr(b.monthly_limit), public.format_idr(s.total))
      else
        format('%s is at %s%% of its monthly limit of %s.',
               c.name, floor((s.total / b.monthly_limit) * 100), public.format_idr(b.monthly_limit))
    end,
    jsonb_build_object(
      'current_amount', s.total,
      'previous_amount', b.monthly_limit,
      'percent_change', round((s.total / b.monthly_limit) * 100, 1)
    )
  from budgets b
  join spend s on s.user_id = b.user_id and s.category_id = b.category_id
  join categories c on c.id = b.category_id
  where b.is_deleted = false
    and b.monthly_limit > 0
    and s.total >= b.monthly_limit * v_budget_warn
    and not exists (
      select 1 from alerts a
      where a.user_id = b.user_id and a.type = 'budget_limit'
        and a.category_id = b.category_id and a.period = v_period
    )
  on conflict (user_id, type, category_id, period) do nothing;
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  -- Rule E: income_received — this month's income already exceeds last
  -- month's total. Needs some income last month to compare against.
  with income as (
    select
      user_id,
      coalesce(sum(amount) filter (where date >= v_month_start), 0) as cur,
      coalesce(sum(amount) filter (where date >= v_prev_month_start and date < v_month_start), 0) as prev
    from transactions
    where type = 'income' and is_deleted = false and date >= v_prev_month_start
    group by user_id
  )
  insert into alerts (user_id, type, category_id, period, message, metadata)
  select
    i.user_id,
    'income_received',
    null,
    v_period,
    format('Income of %s is already above last month (%s).',
           public.format_idr(i.cur), public.format_idr(i.prev)),
    jsonb_build_object(
      'current_amount', i.cur,
      'previous_amount', i.prev,
      'percent_change', round(((i.cur - i.prev) / i.prev) * 100, 1)
    )
  from income i
  where i.prev > 0
    and i.cur > i.prev
    and not exists (
      select 1 from alerts a
      where a.user_id = i.user_id and a.type = 'income_received'
        and a.category_id is null and a.period = v_period
    );
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  -- Rule F: goal_on_track — the mirror of Rule C: a goal with a deadline that
  -- is on or ahead of its linear pace. Waits until the goal is a quarter of
  -- the way to its deadline and has something saved, so a brand-new goal does
  -- not announce itself as "on track" on day one.
  with paced as (
    select
      w.*,
      least(
        greatest(
          extract(epoch from (now() - w.created_at))
            / nullif(extract(epoch from (w.deadline - w.created_at)), 0),
          0
        ),
        1
      ) as expected_fraction
    from wishlist w
    where w.is_deleted = false
      and w.deadline is not null
      and w.deadline > now()
      and w.current_amount > 0
      and w.current_amount < w.target_amount
  )
  insert into alerts (user_id, type, category_id, period, message, metadata)
  select
    p.user_id,
    'goal_on_track',
    null,
    v_period,
    format(
      '"%s" is %s%% funded and on track.',
      p.name,
      round((p.current_amount / p.target_amount) * 100)
    ),
    jsonb_build_object(
      'goal_id', p.id,
      'current_amount', p.current_amount,
      'previous_amount', round(p.target_amount * p.expected_fraction, 2)
    )
  from paced p
  where p.expected_fraction >= v_min_timeline
    and p.current_amount >= (p.target_amount * p.expected_fraction)
    and not exists (
      select 1 from alerts a
      where a.user_id = p.user_id and a.type = 'goal_on_track'
        and a.period = v_period and a.metadata->>'goal_id' = p.id::text
    );
  get diagnostics v_count = row_count;
  v_inserted := v_inserted + v_count;

  return v_inserted;
end;
$$;

revoke all on function public.evaluate_alerts() from public, anon, authenticated;
grant execute on function public.evaluate_alerts() to service_role;
