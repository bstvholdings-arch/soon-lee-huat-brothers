import { createAnonClient } from "@/lib/supabase/client";

export const API_KEY_HEADER = "x-api-key";

/** Extract the API key from the request headers. */
export function getApiKey(req: Request): string | null {
  const fromHeader = req.headers.get(API_KEY_HEADER);
  if (fromHeader) return fromHeader.trim();
  const auth = req.headers.get("authorization");
  if (auth && auth.toLowerCase().startsWith("bearer ")) return auth.slice(7).trim();
  return null;
}

/**
 * Validate the API key via the SECURITY DEFINER function is_api_key_valid().
 * Uses the anon client + RLS — no service_role key needed.
 */
export async function validateApiKey(key: string | null): Promise<boolean> {
  if (!key) return false;
  const supabase = createAnonClient();
  if (!supabase) return false;
  const { data, error } = await supabase.rpc("is_api_key_valid", { p_key: key });
  if (error) return false;
  return Boolean(data);
}

/** Record usage timestamp for analytics (best-effort, ignores errors). */
export async function touchApiKey(key: string): Promise<void> {
  const supabase = createAnonClient();
  if (!supabase) return;
  await supabase.rpc("touch_api_key", { p_key: key });
}
