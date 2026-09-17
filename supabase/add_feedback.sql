-- ===========================================================================
-- Customer feedback (visitor-submitted, admin-reviewed)
-- Run this in the Supabase SQL Editor AFTER supabase/schema.sql.
-- ===========================================================================

create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  name text not null default '',
  rating smallint check (rating between 1 and 5),
  message text not null,
  status text not null default 'pending' check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);

alter table public.feedback enable row level security;

-- Visitors (anon key) can submit feedback; it always lands as 'pending'.
drop policy if exists "feedback_anon_insert_pending" on public.feedback;
create policy "feedback_anon_insert_pending" on public.feedback
  for insert to anon with check (status = 'pending');

-- Visitors can only read already-approved feedback.
drop policy if exists "feedback_anon_select_approved" on public.feedback;
create policy "feedback_anon_select_approved" on public.feedback
  for select to anon using (status = 'approved');

-- Admin (authenticated) can see everything.
drop policy if exists "feedback_auth_select_all" on public.feedback;
create policy "feedback_auth_select_all" on public.feedback
  for select to authenticated using (true);

drop policy if exists "feedback_auth_update_all" on public.feedback;
create policy "feedback_auth_update_all" on public.feedback
  for update to authenticated using (true) with check (true);

drop policy if exists "feedback_auth_delete_all" on public.feedback;
create policy "feedback_auth_delete_all" on public.feedback
  for delete to authenticated using (true);

create index if not exists feedback_status_created_idx
  on public.feedback (status, created_at desc);

-- Verify:
-- select status, count(*) from public.feedback group by status;
