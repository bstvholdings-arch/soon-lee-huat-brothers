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
