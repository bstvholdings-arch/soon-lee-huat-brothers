-- Paste into Supabase SQL Editor and run (after check_address.sql confirms the row exists).
-- Uses ON CONFLICT so it works whether the 'address' row already exists or not.
-- It overwrites ALL three language columns with the CORRECT address.
insert into site_content (section_key, content_en, content_bm, content_zh, images)
values (
  'address',
  '1689 & 1690 Jalan Datok Haji Ahmad Badawi, 13200 Kepala Batas, Pulau Pinang, Kepala Batas, Malaysia',
  '1689 & 1690 Jalan Datok Haji Ahmad Badawi, 13200 Kepala Batas, Pulau Pinang, Kepala Batas, Malaysia',
  '1689 & 1690 Jalan Datok Haji Ahmad Badawi, 13200 Kepala Batas, Pulau Pinang, Kepala Batas, Malaysia'
)
on conflict (section_key) do update
set
  content_en = excluded.content_en,
  content_bm = excluded.content_bm,
  content_zh = excluded.content_zh;

-- Re-run check to confirm the change:
select section_key, content_en from site_content where section_key = 'address';
