import type { Locale, Motorcycle, Part, SiteContent, VehicleImage } from "./types";

export function localized(
  row: { content_en?: string; content_bm?: string; content_zh?: string } | undefined,
  locale: Locale,
  fallback = "",
) {
  if (!row) return fallback;
  const map = { en: row.content_en, bm: row.content_bm, zh: row.content_zh };
  return map[locale] || row.content_en || fallback;
}

export function bikeTitle(bike: Motorcycle, locale: Locale) {
  const map = { en: bike.title_en, bm: bike.title_bm, zh: bike.title_zh };
  return map[locale] || bike.title_en;
}

export function partName(part: Part, locale: Locale) {
  const map = { en: part.name_en, bm: part.name_bm, zh: part.name_zh };
  return map[locale] || part.name_en;
}

export function colorName(image: VehicleImage, locale: Locale) {
  const map = { en: image.color_name_en, bm: image.color_name_bm, zh: image.color_name_zh };
  return map[locale] || image.color_name_en;
}

export function contentText(
  map: Record<string, SiteContent>,
  key: string,
  locale: Locale,
  fallback = "",
) {
  return localized(map[key], locale, fallback);
}

export function formatMYR(amount: number) {
  return new Intl.NumberFormat("en-MY", {
    style: "currency",
    currency: "MYR",
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatNumber(amount: number) {
  return new Intl.NumberFormat("en-MY", { maximumFractionDigits: 2 }).format(amount);
}

export function digitsOnly(value: string) {
  return value.replace(/\D/g, "");
}

export function whatsappLink(phone: string, message: string) {
  const digits = digitsOnly(phone);
  if (!digits) return "#";
  return `https://wa.me/${digits}?text=${encodeURIComponent(message)}`;
}

export function telLink(phone: string) {
  const digits = digitsOnly(phone);
  return digits ? `tel:+${digits}` : "#";
}

export function mapLink(address: string) {
  const q = encodeURIComponent((address ?? "").trim());
  return q ? `https://www.google.com/maps/search/?api=1&query=${q}` : "#";
}

export function contentMap(rows: SiteContent[]) {
  return Object.fromEntries(rows.map((row) => [row.section_key, row]));
}

export function mainImage(bike: Motorcycle) {
  const images = bike.vehicle_images ?? [];
  return images.find((img) => img.is_main) ?? images.find((img) => img.angle_type === "main") ?? images[0];
}
