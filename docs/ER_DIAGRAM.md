# Soon Lee Huat Motor — Database ER Diagram

Supabase (PostgreSQL) · ref `tyfcdbsiomsrramszqxc`
8 tables · RLS enabled (public read, authenticated write)

```mermaid
erDiagram
    %% ===== Core catalog =====
    motorcycles {
        uuid id PK
        text type "new|used"
        text title_en
        text title_bm
        text title_zh
        numeric price
        int year
        int mileage
        jsonb specs
        text status "available|sold"
        text sku
        int stock_quantity
        timestamptz created_at
    }
    vehicle_images {
        uuid id PK
        uuid motorcycle_id FK
        text color_name_en
        text color_name_bm
        text color_zh
        text color_hex
        text image_url
        bool is_main
        text angle_type "main|exhaust|caliper|dashboard"
        timestamptz created_at
    }
    parts {
        uuid id PK
        text name_en
        text name_bm
        text name_zh
        text category
        text applicable_model
        numeric price
        text image_url
        text stock_status "in_stock|low|out"
        text sku
        int stock_quantity
        timestamptz created_at
    }
    brands {
        uuid id PK
        text brand_name
        text logo_url
        int display_order
    }
    site_content {
        uuid id PK
        text section_key UK "company_name,phone,whatsapp,address,hours,maps_url,waze_url,hero_tagline,hero_subtitle,about,company_reg,gallery"
        text content_en
        text content_bm
        text content_zh
        text[] images
    }

    %% ===== API access & orders =====
    api_keys {
        uuid id PK
        uuid owner FK "auth.users"
        text name
        text key UK
        bool revoked
        timestamptz created_at
        timestamptz last_used_at
    }
    orders {
        uuid id PK
        text order_number UK "SLH-YYYYMMDD-xxxxxx"
        text buyer_name
        text buyer_email
        text buyer_phone
        jsonb shipping_address
        text status "pending_shipment|shipped|delivered|cancelled"
        text external_ref
        text notes
        timestamptz created_at
    }
    order_items {
        uuid id PK
        uuid order_id FK
        text product_type "motorcycle|part"
        text sku
        text name
        int quantity
        numeric unit_price
    }

    %% ===== Relationships =====
    motorcycles ||--o{ vehicle_images : "has colours/angles"
    orders ||--o{ order_items : "contains"
    auth_users ||--o{ api_keys : "owns"
    api_keys }o..o{ orders : "used_by (Bearer auth, no FK)"

    %% order_items references motorcycles/parts only by sku (no FK, validated in create_order())
    note for order_items "sku links to motorcycles.sku / parts.sku (checked in create_order SECURITY DEFINER)"
```

## Storage buckets (public)
`vehicle-images` · `part-images` · `brand-logos` · `gallery`

## Access pattern
- Public site: anon client → read motorcycles / parts / brands / site_content
- Admin: authenticated Supabase Auth → write all tables
- External v1 API: `Authorization: Bearer <api_key>` → `api_keys` table
  - `GET /api/v1/products` — return sku + price + stock_quantity + status
  - `POST /api/v1/orders` — `create_order()` deducts real stock (unknown_sku→400, insufficient_stock→409)
  - On failure → WhatsApp alert via `notify.ts` (Meta Cloud API)
