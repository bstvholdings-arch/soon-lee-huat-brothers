import type { SupabaseClient } from "@supabase/supabase-js";

export async function uploadPublicFile(
  supabase: SupabaseClient,
  bucket: string,
  file: File,
) {
  const ext = file.name.split(".").pop() || "jpg";
  const path = `${Date.now()}-${crypto.randomUUID()}.${ext}`;
  const { error } = await supabase.storage.from(bucket).upload(path, file, { upsert: false });
  if (error) throw error;
  const { data } = supabase.storage.from(bucket).getPublicUrl(path);
  return data.publicUrl;
}
