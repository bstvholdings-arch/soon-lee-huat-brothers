-- ============================================================================
-- harden_admin_rls.sql
-- Harden RLS so only the admin role (auth.users.app_metadata -> role = 'admin')
-- can write site data and storage. Anonymous visitors keep read access.
--
-- Idempotent: it drops the old "any authenticated user" policies (by name)
-- and creates admin-only ones. Safe to re-run after schema.sql / add_*.sql.
-- Run this in Supabase SQL Editor (you are a Postgres superuser there), then
-- set the admin user's app_metadata (see steps in chat).
-- ============================================================================

-- Helper: is the current request made by an admin? (reads JWT app_metadata)
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin', false);
$$;

-- ---------------------------------------------------------------------------
-- Table policies: public read, admin-only write (replace "auth write *" ones)
-- ---------------------------------------------------------------------------

drop policy if exists "auth write parts"            on public.parts;
drop policy if exists "auth write brands"           on public.brands;
drop policy if exists "auth write site_content"     on public.site_content;
drop policy if exists "auth write motorcycles"      on public.motorcycles;
drop policy if exists "auth write orders"           on public.orders;
drop policy if exists "auth write order_items"      on public.order_items;
drop policy if exists "auth write api_keys"         on public.api_keys;
drop policy if exists "auth write feedback"         on public.feedback;
drop policy if exists "auth write vehicle_images"   on public.vehicle_images;

create policy "admin write motorcycles"
  on public.motorcycles for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "admin write parts"
  on public.parts for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "admin write brands"
  on public.brands for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "admin write site_content"
  on public.site_content for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "admin write orders"
  on public.orders for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "admin write order_items"
  on public.order_items for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "admin write api_keys"
  on public.api_keys for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "admin write feedback"
  on public.feedback for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

create policy "admin write vehicle_images"
  on public.vehicle_images for all
  to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ---------------------------------------------------------------------------
-- Storage policies: public read, admin-only write on the 4 buckets
-- (the original "auth write *" policies allowed ANY logged-in user to upload)
-- ---------------------------------------------------------------------------

drop policy if exists "auth write vehicle-images" on storage.objects;
drop policy if exists "auth write part-images"    on storage.objects;
drop policy if exists "auth write brand-logos"    on storage.objects;
drop policy if exists "auth write gallery"        on storage.objects;

create policy "admin write vehicle-images"
  on storage.objects for all
  to authenticated
  using (bucket_id = 'vehicle-images' and public.is_admin())
  with check (bucket_id = 'vehicle-images' and public.is_admin());

create policy "admin write part-images"
  on storage.objects for all
  to authenticated
  using (bucket_id = 'part-images' and public.is_admin())
  with check (bucket_id = 'part-images' and public.is_admin());

create policy "admin write brand-logos"
  on storage.objects for all
  to authenticated
  using (bucket_id = 'brand-logos' and public.is_admin())
  with check (bucket_id = 'brand-logos' and public.is_admin());

create policy "admin write gallery"
  on storage.objects for all
  to authenticated
  using (bucket_id = 'gallery' and public.is_admin())
  with check (bucket_id = 'gallery' and public.is_admin());

-- Note: keep the existing "public read *" policies (using (true)) untouched so
-- the public site and /api/v1 still work for anonymous visitors.
