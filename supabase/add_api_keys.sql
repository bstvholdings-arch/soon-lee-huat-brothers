-- ===========================================================================
-- API key management for external consumers (Soon Lee Huat Motor)
-- Run this in the Supabase SQL Editor AFTER supabase/schema.sql.
-- ===========================================================================

create extension if not exists "pgcrypto";

-- Key is stored in plaintext for simple "view/reveal" in the admin UI.
-- Trade-off: rotate keys if leaked. For stronger security, switch to a
-- sha256 hash column + issue the plaintext only once (see note at bottom).
create table if not exists public.api_keys (
  id uuid primary key default gen_random_uuid(),
  owner uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name text not null default '',
  key text not null unique,
  revoked boolean not null default false,
  created_at timestamptz not null default now(),
  last_used_at timestamptz
);

alter table public.api_keys enable row level security;

drop policy if exists "api_keys_select_own" on public.api_keys;
create policy "api_keys_select_own" on public.api_keys
  for select to authenticated using (owner = auth.uid());

drop policy if exists "api_keys_insert_own" on public.api_keys;
create policy "api_keys_insert_own" on public.api_keys
  for insert to authenticated with check (owner = auth.uid());

drop policy if exists "api_keys_delete_own" on public.api_keys;
create policy "api_keys_delete_own" on public.api_keys
  for delete to authenticated using (owner = auth.uid());

-- SECURITY DEFINER so anon callers can validate a key without reading the table.
create or replace function public.is_api_key_valid(p_key text)
returns boolean language sql security definer set search_path = public as $$
  select exists (
    select 1 from public.api_keys where key = p_key and revoked = false
  );
$$;

create or replace function public.touch_api_key(p_key text)
returns void language sql security definer set search_path = public as $$
  update public.api_keys set last_used_at = now() where key = p_key and revoked = false;
$$;

grant execute on function public.is_api_key_valid(text) to anon, authenticated;
grant execute on function public.touch_api_key(text) to anon, authenticated;

-- ---------------------------------------------------------------------------
-- (Optional hardening) Store only a sha256 hash instead of plaintext:
--   alter table public.api_keys add column key_hash text unique;
--   create or replace function public.is_api_key_valid(p_key text)
--   returns boolean language sql security definer set search_path = public as $$
--     select exists (select 1 from public.api_keys
--       where key_hash = encode(digest(p_key, 'sha256'), 'hex') and revoked = false);
--   $$;
-- Then have the admin page compute the hash client-side and never store the raw key.
-- ---------------------------------------------------------------------------
