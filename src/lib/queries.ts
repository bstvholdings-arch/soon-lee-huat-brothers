import { createServerSupabase } from "./supabase/server";
import { contentMap } from "./i18n";
import type { Brand, Motorcycle, Part, SiteContent } from "./types";

const bikeSelect = "*, vehicle_images(*)";

export async function getSiteContent() {
  const supabase = await createServerSupabase();
  if (!supabase) return contentMap([]);
  const { data } = await supabase.from("site_content").select("*");
  return contentMap((data ?? []) as SiteContent[]);
}

export async function getMotorcycles(type: "new" | "used") {
  const supabase = await createServerSupabase();
  if (!supabase) return [] as Motorcycle[];
  const { data } = await supabase
    .from("motorcycles")
    .select(bikeSelect)
    .eq("type", type)
    .order("created_at", { ascending: false });
  return (data ?? []) as Motorcycle[];
}

export async function getMotorcycle(id: string) {
  const supabase = await createServerSupabase();
  if (!supabase) return null;
  const { data } = await supabase.from("motorcycles").select(bikeSelect).eq("id", id).maybeSingle();
  return (data as Motorcycle | null) ?? null;
}

export async function getBrands() {
  const supabase = await createServerSupabase();
  if (!supabase) return [] as Brand[];
  const { data } = await supabase.from("brands").select("*").order("display_order", { ascending: true });
  return (data ?? []) as Brand[];
}

export async function getParts() {
  const supabase = await createServerSupabase();
  if (!supabase) return [] as Part[];
  const { data } = await supabase.from("parts").select("*").order("created_at", { ascending: false });
  return (data ?? []) as Part[];
}
