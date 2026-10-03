-- Optional monthly spending limit per category, per user.
--
-- This is its own table rather than a column on categories: the default
-- categories are shared rows (user_id is null) that no user can update, yet a
-- user must be able to set a limit on "Food" or "Dining" for themselves. A
-- category without a row here simply has no limit.
--
-- The app derives each row's id from (user, category), so there is at most one
-- row per pair and an upsert by id never collides with the unique constraint.
-- Clearing a limit is a soft delete (is_deleted), like the other synced tables.
--
-- Idempotent: policies and triggers are dropped and recreated.

create table if not exists public.budgets (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete cascade,
  monthly_limit numeric(18, 2) not null check (monthly_limit > 0),
  is_deleted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, category_id)
);

create index if not exists budgets_user_updated_idx
  on public.budgets (user_id, updated_at);

alter table public.budgets enable row level security;

drop policy if exists "budgets_select_own" on public.budgets;
create policy "budgets_select_own" on public.budgets
  for select using (auth.uid() = user_id);
drop policy if exists "budgets_insert_own" on public.budgets;
create policy "budgets_insert_own" on public.budgets
  for insert with check (auth.uid() = user_id);
drop policy if exists "budgets_update_own" on public.budgets;
create policy "budgets_update_own" on public.budgets
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "budgets_delete_own" on public.budgets;
create policy "budgets_delete_own" on public.budgets
  for delete using (auth.uid() = user_id);

drop trigger if exists budgets_touch_updated_at on public.budgets;
create trigger budgets_touch_updated_at
  before update on public.budgets
  for each row execute function public.touch_updated_at();
