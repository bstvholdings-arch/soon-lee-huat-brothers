-- Paste into Supabase SQL Editor and run.
-- This shows exactly what is currently stored for the address row.
-- If content_en still shows the OLD "Penaga / 13100 / Datuk" value,
-- then the previous UPDATE did not affect this project's row
-- (wrong project, or 0 rows matched).
select
  id,
  section_key,
  content_en,
  content_bm,
  content_zh
from site_content
where section_key = 'address';
