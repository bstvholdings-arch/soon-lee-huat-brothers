import { createAnonClient } from "@/lib/supabase/client";

/**
 * Validate a Bearer token (the API key generated in the Admin > API keys page)
 * against the api_keys table via the SECURITY DEFINER function.
 * No service_role key is used here.
 */
export async function authenticateV1(req: Request): Promise<{ ok: boolean; key: string | null }> {
  const auth = req.headers.get("authorization");
  if (!auth || !auth.toLowerCase().startsWith("bearer ")) {
    return { ok: false, key: null };
  }
  const key = auth.slice(7).trim();
  if (!key) return { ok: false, key: null };

  const supabase = createAnonClient();
  if (!supabase) return { ok: false, key: null };

  const { data, error } = await supabase.rpc("is_api_key_valid", { p_key: key });
  if (error || !data) return { ok: false, key: null };

  return { ok: Boolean(data), key };
}

/** Record usage timestamp (best-effort). */
export async function touchV1(key: string): Promise<void> {
  const supabase = createAnonClient();
  if (!supabase) return;
  await supabase.rpc("touch_api_key", { p_key: key });
}
