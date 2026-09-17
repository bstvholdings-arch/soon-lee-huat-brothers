-- Paste into Supabase SQL Editor and run once.
-- Adds the 3 social-link rows (empty by default). Fill them later
-- in the admin Content & gallery page under "Social links".
-- Uses ON CONFLICT so it is safe to re-run.
insert into site_content (section_key, content_en, content_bm, content_zh, images)
values
  ('facebook_url',  '', '', '', '{}'),
  ('tiktok_url',    '', '', '', '{}'),
  ('instagram_url', '', '', '', '{}')
on conflict (section_key) do nothing;

-- Verify:
select section_key, content_en from site_content
where section_key in ('facebook_url', 'tiktok_url', 'instagram_url');
