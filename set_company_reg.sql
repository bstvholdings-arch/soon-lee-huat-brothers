-- Set the company registration number shown under the company name on the home hero.
-- Run this in Supabase SQL Editor (schema.sql must already be applied).
insert into public.site_content (section_key, content_en, content_bm, content_zh, images)
values ('company_reg', '201901003575 (1312901-T)', '201901003575 (1312901-T)', '201901003575 (1312901-T)', '{}')
on conflict (section_key) do update
  set content_en = excluded.content_en,
      content_bm = excluded.content_bm,
      content_zh = excluded.content_zh;
