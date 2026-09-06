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
