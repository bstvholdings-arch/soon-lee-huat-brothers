-- (Optional) If /admin shows errors or empty, run supabase/schema.sql first.
-- Then run this to set the WhatsApp / phone number directly:
insert into public.site_content (section_key, content_en, content_bm, content_zh, images)
values
  ('whatsapp', '+60174096251', '+60174096251', '+60174096251', '{}'),
  ('phone',    '+60174096251', '+60174096251', '+60174096251', '{}')
on conflict (section_key) do update
  set content_en = excluded.content_en,
      content_bm = excluded.content_bm,
      content_zh = excluded.content_zh;
