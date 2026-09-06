-- Soon Lee Huat Motor - ONE-SHOT SETUP (paste entire file into Supabase SQL Editor, click Run). Idempotent.  
-- Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.
-- Run this in the Supabase SQL editor (or via supabase db push).

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists public.motorcycles (
  id uuid primary key default gen_random_uuid(),
  type text not null check (type in ('new', 'used')),
  title_en text not null default '',
  title_bm text not null default '',
  title_zh text not null default '',
  price numeric(12, 2) not null default 0,
  year integer,
  mileage integer,
  specs jsonb not null default '{}'::jsonb,
  status text not null default 'available' check (status in ('available', 'sold')),
  created_at timestamptz not null default now()
);

create table if not exists public.vehicle_images (
  id uuid primary key default gen_random_uuid(),
  motorcycle_id uuid not null references public.motorcycles (id) on delete cascade,
  color_name_en text not null default '',
  color_name_bm text not null default '',
  color_name_zh text not null default '',
  color_hex text not null default '#111111',
  image_url text not null default '',
  is_main boolean not null default false,
  angle_type text not null default 'main' check (angle_type in ('main', 'exhaust', 'caliper', 'dashboard')),
  created_at timestamptz not null default now()
);

create table if not exists public.parts (
  id uuid primary key default gen_random_uuid(),
  name_en text not null default '',
  name_bm text not null default '',
  name_zh text not null default '',
  category text not null default '',
  applicable_model text not null default '',
  price numeric(12, 2) not null default 0,
  image_url text not null default '',
  stock_status text not null default 'in_stock' check (stock_status in ('in_stock', 'low', 'out')),
  created_at timestamptz not null default now()
);

create table if not exists public.brands (
  id uuid primary key default gen_random_uuid(),
  brand_name text not null default '',
  logo_url text not null default '',
  display_order integer not null default 0
);

create table if not exists public.site_content (
  id uuid primary key default gen_random_uuid(),
  section_key text not null unique,
  content_en text not null default '',
  content_bm text not null default '',
  content_zh text not null default '',
  images text[] not null default '{}'::text[]
);

create index if not exists motorcycles_type_idx on public.motorcycles (type, status, created_at desc);
create index if not exists vehicle_images_moto_idx on public.vehicle_images (motorcycle_id);
create index if not exists parts_category_idx on public.parts (category);
create index if not exists brands_order_idx on public.brands (display_order);

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.motorcycles enable row level security;
alter table public.vehicle_images enable row level security;
alter table public.parts enable row level security;
alter table public.brands enable row level security;
alter table public.site_content enable row level security;

drop policy if exists "public read motorcycles" on public.motorcycles;
drop policy if exists "auth write motorcycles" on public.motorcycles;
create policy "public read motorcycles" on public.motorcycles for select using (true);
create policy "auth write motorcycles" on public.motorcycles
  for all to authenticated using (true) with check (true);

drop policy if exists "public read vehicle_images" on public.vehicle_images;
drop policy if exists "auth write vehicle_images" on public.vehicle_images;
create policy "public read vehicle_images" on public.vehicle_images for select using (true);
create policy "auth write vehicle_images" on public.vehicle_images
  for all to authenticated using (true) with check (true);

drop policy if exists "public read parts" on public.parts;
drop policy if exists "auth write parts" on public.parts;
create policy "public read parts" on public.parts for select using (true);
create policy "auth write parts" on public.parts
  for all to authenticated using (true) with check (true);

drop policy if exists "public read brands" on public.brands;
drop policy if exists "auth write brands" on public.brands;
create policy "public read brands" on public.brands for select using (true);
create policy "auth write brands" on public.brands
  for all to authenticated using (true) with check (true);

drop policy if exists "public read site_content" on public.site_content;
drop policy if exists "auth write site_content" on public.site_content;
create policy "public read site_content" on public.site_content for select using (true);
create policy "auth write site_content" on public.site_content
  for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------------
-- Storage buckets
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public)
values
  ('vehicle-images', 'vehicle-images', true),
  ('part-images', 'part-images', true),
  ('brand-logos', 'brand-logos', true),
  ('gallery', 'gallery', true)
on conflict (id) do nothing;

drop policy if exists "public read vehicle-images" on storage.objects;
drop policy if exists "auth write vehicle-images" on storage.objects;
drop policy if exists "public read part-images" on storage.objects;
drop policy if exists "auth write part-images" on storage.objects;
drop policy if exists "public read brand-logos" on storage.objects;
drop policy if exists "auth write brand-logos" on storage.objects;
drop policy if exists "public read gallery" on storage.objects;
drop policy if exists "auth write gallery" on storage.objects;

create policy "public read vehicle-images" on storage.objects
  for select using (bucket_id = 'vehicle-images');
create policy "auth write vehicle-images" on storage.objects
  for all to authenticated using (bucket_id = 'vehicle-images') with check (bucket_id = 'vehicle-images');

create policy "public read part-images" on storage.objects
  for select using (bucket_id = 'part-images');
create policy "auth write part-images" on storage.objects
  for all to authenticated using (bucket_id = 'part-images') with check (bucket_id = 'part-images');

create policy "public read brand-logos" on storage.objects
  for select using (bucket_id = 'brand-logos');
create policy "auth write brand-logos" on storage.objects
  for all to authenticated using (bucket_id = 'brand-logos') with check (bucket_id = 'brand-logos');

create policy "public read gallery" on storage.objects
  for select using (bucket_id = 'gallery');
create policy "auth write gallery" on storage.objects
  for all to authenticated using (bucket_id = 'gallery') with check (bucket_id = 'gallery');

-- ---------------------------------------------------------------------------
-- Seed CMS copy (edit later in /admin)
-- ---------------------------------------------------------------------------

insert into public.site_content (section_key, content_en, content_bm, content_zh, images)
values
  ('company_name', 'Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.', 'Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.', 'Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.', '{}'),
  ('phone', '', '', '', '{}'),
  ('whatsapp', '', '', '', '{}'),
  ('address', 'Kepala Batas, Penang, Malaysia', 'Kepala Batas, Pulau Pinang, Malaysia', '马来西亚槟城甲抛峇底', '{}'),
  ('hours', '', '', '', '{}'),
  ('maps_url', '', '', '', '{}'),
  ('waze_url', '', '', '', '{}'),
  ('hero_tagline', 'New & used motorcycles, genuine parts, and friendly service in Kepala Batas.', 'Motosikal baru & terpakai, alat ganti tulen, dan servis mesra di Kepala Batas.', '甲抛峇底新车与二手电单车、原厂零件与贴心服务。', '{}'),
  ('hero_subtitle', 'Visit our showroom or enquire on WhatsApp — we will help you find the right ride and loan plan.', 'Lawati showroom kami atau tanya melalui WhatsApp — kami bantu cari motosikal dan pinjaman yang sesuai.', '欢迎莅临展厅或通过 WhatsApp 查询，我们协助您选车与贷款方案。', '{}'),
  ('about', 'Soon Lee Huat Brothers Motor (KB) Sdn. Bhd. is a motorcycle dealer in Kepala Batas, Penang. We offer new motorcycles, quality pre-owned bikes, parts and accessories, and workshop support for riders in Seberang Perai Utara.', 'Soon Lee Huat Brothers Motor (KB) Sdn. Bhd. ialah peniaga motosikal di Kepala Batas, Pulau Pinang. Kami menawarkan motosikal baharu, motosikal terpakai berkualiti, alat ganti serta sokongan bengkel untuk penunggang di Seberang Perai Utara.', 'Soon Lee Huat Brothers Motor (KB) Sdn. Bhd. 是位于槟城甲抛峇底的电单车经销商。我们提供新车、优质二手车、零件配件，以及为威北骑手提供维修支援。', '{}'),
  ('gallery', '', '', '', '{}')
on conflict (section_key) do nothing;
  
-- ===================== (2) API KEYS =====================  
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
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- =================== (3) ORDERS + SKU/STOCK ===================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ================== (3) ORDERS + SKU/STOCK ==================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ================= (3) ORDERS + SKU/STOCK =================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- =================== (3) ORDERS + SKU/STOCK ===================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ================== (3) ORDERS + SKU/STOCK ==================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
  
-- ===================== (3) ORDERS + SKU/STOCK =====================  
-- ===========================================================================
-- External API support: SKU + stock on products, and orders tables.
-- Run this in the Supabase SQL Editor AFTER schema.sql and add_api_keys.sql.
-- ===========================================================================

-- 1) Add SKU + numeric stock to products so external systems can sync inventory.
alter table public.motorcycles add column if not exists sku text not null default '';
alter table public.motorcycles add column if not exists stock_quantity integer not null default 0;
alter table public.parts add column if not exists sku text not null default '';
alter table public.parts add column if not exists stock_quantity integer not null default 0;

-- 2) Orders + items.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  buyer_name text not null,
  buyer_email text,
  buyer_phone text,
  shipping_address jsonb not null default '{}'::jsonb,
  status text not null default 'pending_shipment'
    check (status in ('pending_shipment', 'shipped', 'delivered', 'cancelled')),
  external_ref text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders (id) on delete cascade,
  product_type text not null check (product_type in ('motorcycle', 'part')),
  sku text not null default '',
  name text not null default '',
  quantity integer not null default 1,
  unit_price numeric(12, 2) not null default 0
);

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Staff (authenticated admin) can read orders to process them.
drop policy if exists "orders_select_authenticated" on public.orders;
create policy "orders_select_authenticated" on public.orders
  for select to authenticated using (true);
drop policy if exists "orders_update_authenticated" on public.orders;
create policy "orders_update_authenticated" on public.orders
  for update to authenticated using (true) with check (true);
drop policy if exists "order_items_select_authenticated" on public.order_items;
create policy "order_items_select_authenticated" on public.order_items
  for select to authenticated using (true);

-- 3) Secure order creation. SECURITY DEFINER so anon API callers can write
--    without a broad insert RLS policy. Validates inventory and decrements stock.
create or replace function public.create_order(
  p_buyer_name text,
  p_buyer_email text,
  p_buyer_phone text,
  p_shipping_address jsonb,
  p_notes text,
  p_external_ref text,
  p_items jsonb
) returns jsonb language plpgsql security definer set search_path = public as $$
declare
  new_id uuid;
  new_number text;
  item jsonb;
  avail int;
begin
  if p_buyer_name is null or p_buyer_name = '' then
    raise exception 'missing_buyer_name';
  end if;
  if p_items is null or jsonb_array_length(p_items) = 0 then
    raise exception 'missing_items';
  end if;

  -- inventory check (raise on unknown sku / insufficient stock)
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      select stock_quantity into avail from public.motorcycles where sku = (item->>'sku');
    else
      select stock_quantity into avail from public.parts where sku = (item->>'sku');
    end if;
    if avail is null then
      raise exception 'unknown_sku:%', (item->>'sku');
    end if;
    if avail < (item->>'quantity')::int then
      raise exception 'insufficient_stock:%', (item->>'sku');
    end if;
  end loop;

  insert into public.orders (buyer_name, buyer_email, buyer_phone, shipping_address, notes, external_ref, status)
  values (p_buyer_name, p_buyer_email, p_buyer_phone, coalesce(p_shipping_address, '{}'::jsonb), p_notes, p_external_ref, 'pending_shipment')
  returning id into new_id;

  new_number := 'SLH-' || to_char(now(), 'YYYYMMDD') || '-' || substr(replace(new_id::text, '-', ''), 1, 6);
  update public.orders set order_number = new_number where id = new_id;

  insert into public.order_items (order_id, product_type, sku, name, quantity, unit_price)
  select new_id,
         (item->>'product_type'),
         coalesce(item->>'sku', ''),
         coalesce(item->>'name', ''),
         (item->>'quantity')::int,
         (item->>'unit_price')::numeric
  from jsonb_array_elements(p_items) as item;

  -- decrement real-time stock
  for item in select * from jsonb_array_elements(p_items) loop
    if (item->>'product_type') = 'motorcycle' then
      update public.motorcycles set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    else
      update public.parts set stock_quantity = stock_quantity - (item->>'quantity')::int where sku = (item->>'sku');
    end if;
  end loop;

  return jsonb_build_object('order_id', new_id, 'order_number', new_number, 'status', 'pending_shipment');
end;
$$;

grant execute on function public.create_order(text, text, text, jsonb, text, text, jsonb)
  to anon, authenticated;
