-- Base schema for categories, transactions and wishlist, reconstructed from
-- the Flutter models (lib/data/models) and SyncService. Idempotent (policies/triggers are
-- dropped and recreated), so it is safe to run where these tables already exist.
-- Column types/constraints are inferred, so diff against the live schema first. Must sort
-- before 20260724000000_alerts.sql, which references public.categories.

-- Shared trigger: the client sets updated_at itself, but keep it honest for
-- writes that bypass the app (SQL editor, other clients).
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  if new.updated_at is null or new.updated_at = old.updated_at then
    new.updated_at = now();
  end if;
  return new;
end;
$$;

-- 1. categories (user_id null = global default, readable by everyone)
create table if not exists public.categories (
  id uuid primary key,
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  icon text not null,
  type text not null check (type in ('income', 'expense')),
  is_deleted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists categories_user_updated_idx
  on public.categories (user_id, updated_at);

alter table public.categories enable row level security;

drop policy if exists "categories_select_own_or_global" on public.categories;
create policy "categories_select_own_or_global" on public.categories
  for select using (user_id is null or auth.uid() = user_id);
drop policy if exists "categories_insert_own" on public.categories;
create policy "categories_insert_own" on public.categories
  for insert with check (auth.uid() = user_id);
drop policy if exists "categories_update_own" on public.categories;
create policy "categories_update_own" on public.categories
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "categories_delete_own" on public.categories;
create policy "categories_delete_own" on public.categories
  for delete using (auth.uid() = user_id);

drop trigger if exists categories_touch_updated_at on public.categories;
create trigger categories_touch_updated_at
  before update on public.categories
  for each row execute function public.touch_updated_at();

-- 2. transactions
create table if not exists public.transactions (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  amount numeric(18, 2) not null check (amount >= 0),
  type text not null check (type in ('income', 'expense')),
  category_id uuid not null references public.categories(id),
  note text,
  date timestamptz not null,
  is_deleted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists transactions_user_updated_idx
  on public.transactions (user_id, updated_at);
create index if not exists transactions_user_date_idx
  on public.transactions (user_id, date desc);

alter table public.transactions enable row level security;

drop policy if exists "transactions_select_own" on public.transactions;
create policy "transactions_select_own" on public.transactions
  for select using (auth.uid() = user_id);
drop policy if exists "transactions_insert_own" on public.transactions;
create policy "transactions_insert_own" on public.transactions
  for insert with check (auth.uid() = user_id);
drop policy if exists "transactions_update_own" on public.transactions;
create policy "transactions_update_own" on public.transactions
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "transactions_delete_own" on public.transactions;
create policy "transactions_delete_own" on public.transactions
  for delete using (auth.uid() = user_id);

drop trigger if exists transactions_touch_updated_at on public.transactions;
create trigger transactions_touch_updated_at
  before update on public.transactions
  for each row execute function public.touch_updated_at();

-- 3. wishlist
create table if not exists public.wishlist (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  target_amount numeric(18, 2) not null check (target_amount > 0),
  current_amount numeric(18, 2) not null default 0 check (current_amount >= 0),
  deadline timestamptz,
  notified_completed boolean not null default false,
  is_deleted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists wishlist_user_updated_idx
  on public.wishlist (user_id, updated_at);

alter table public.wishlist enable row level security;

drop policy if exists "wishlist_select_own" on public.wishlist;
create policy "wishlist_select_own" on public.wishlist
  for select using (auth.uid() = user_id);
drop policy if exists "wishlist_insert_own" on public.wishlist;
create policy "wishlist_insert_own" on public.wishlist
  for insert with check (auth.uid() = user_id);
drop policy if exists "wishlist_update_own" on public.wishlist;
create policy "wishlist_update_own" on public.wishlist
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "wishlist_delete_own" on public.wishlist;
create policy "wishlist_delete_own" on public.wishlist
  for delete using (auth.uid() = user_id);

drop trigger if exists wishlist_touch_updated_at on public.wishlist;
create trigger wishlist_touch_updated_at
  before update on public.wishlist
  for each row execute function public.touch_updated_at();

-- 4. Seed global default categories. Fixed UUIDs must match
-- lib/core/constants/default_categories.dart.
insert into public.categories (id, name, icon, type) values
  ('00000000-0000-4000-8000-000000000001', 'Salary', 'work', 'income'),
  ('00000000-0000-4000-8000-000000000002', 'Business', 'store', 'income'),
  ('00000000-0000-4000-8000-000000000003', 'Gift', 'card_giftcard', 'income'),
  ('00000000-0000-4000-8000-000000000004', 'Other Income', 'attach_money', 'income'),
  ('00000000-0000-4000-8000-000000000005', 'Food', 'restaurant', 'expense'),
  ('00000000-0000-4000-8000-000000000006', 'Transport', 'directions_car', 'expense'),
  ('00000000-0000-4000-8000-000000000007', 'Shopping', 'shopping_bag', 'expense'),
  ('00000000-0000-4000-8000-000000000008', 'Bills', 'receipt_long', 'expense'),
  ('00000000-0000-4000-8000-000000000009', 'Entertainment', 'movie', 'expense'),
  ('00000000-0000-4000-8000-000000000010', 'Health', 'local_hospital', 'expense'),
  ('00000000-0000-4000-8000-000000000011', 'Education', 'school', 'expense'),
  ('00000000-0000-4000-8000-000000000012', 'Other Expense', 'category', 'expense')
on conflict (id) do nothing;
