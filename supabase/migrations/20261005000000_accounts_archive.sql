-- Lets an account be archived: hidden from pickers and lists, but its history
-- and balance are kept (a deleted account, by contrast, disappears).
--
-- Additive and idempotent. Existing rows become not archived. Nothing else in
-- the live schema is touched, and a client that never mentions the column
-- (an upsert that leaves it out) leaves each row's value as it is.
--
-- Run this once, before releasing the app version that archives accounts.

alter table public.accounts
  add column if not exists is_archived boolean not null default false;
