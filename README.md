# Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.

Trilingual motorcycle dealership website (EN / BM / 中文) built with Next.js App Router, Tailwind CSS, and Supabase. All catalogue, brand, gallery, and contact content is managed from `/admin`.

## Setup

1. Create a Supabase project.
2. In the SQL editor, run [`supabase/schema.sql`](supabase/schema.sql). This creates tables, RLS policies, public storage buckets, and starter `site_content` rows.
3. Authentication: **Authentication → Users → Add user** with an email/password for CMS staff.
4. Copy `.env.example` to `.env.local` and fill in:

```
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

5. Install and run:

```
npm install
npm run dev
```

6. Open [http://localhost:3000](http://localhost:3000) for the public site and [http://localhost:3000/admin](http://localhost:3000/admin) for the CMS.

## What to fill in the CMS first

- **Content & gallery:** phone, WhatsApp number (digits with country code, e.g. `6012xxxxxxx`), address, hours, Maps/Waze URLs, About copy, store photos.
- **Motorcycles:** new and used listings with colour photos and detail angles.
- **Parts** and **Brands**.

## Deploy (Vercel)

Connect the Git repo to Vercel and add the same `NEXT_PUBLIC_SUPABASE_*` environment variables. After the first deploy, add your Vercel domain under Supabase **Authentication → URL configuration**.
"# test" 
