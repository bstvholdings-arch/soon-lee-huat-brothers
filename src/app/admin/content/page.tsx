"use client";

import { FormEvent, useEffect, useState } from "react";
import { AdminNav } from "@/components/admin/admin-nav";
import { createBrowserSupabase } from "@/lib/supabase/client";
import { uploadPublicFile } from "@/lib/upload";
import type { SiteContent } from "@/lib/types";

const KEYS = [
  "company_name",
  "phone",
  "whatsapp",
  "company_reg",
  "address",
  "hours",
  "maps_url",
  "waze_url",
  "hero_tagline",
  "hero_subtitle",
  "about",
  "gallery",
] as const;

export default function AdminContentPage() {
  const [rows, setRows] = useState<SiteContent[]>([]);
  const [error, setError] = useState("");
  const [saving, setSaving] = useState(false);

  async function load() {
    const supabase = createBrowserSupabase();
    const { data, error: qErr } = await supabase.from("site_content").select("*");
    if (qErr) setError(qErr.message);
    else setRows((data ?? []) as SiteContent[]);
  }

  useEffect(() => {
    void load();
  }, []);

  function get(key: string): SiteContent {
    return (
      rows.find((r) => r.section_key === key) ?? {
        id: "",
        section_key: key,
        content_en: "",
        content_bm: "",
        content_zh: "",
        images: [],
      }
    );
  }

  function patch(key: string, next: Partial<SiteContent>) {
    setRows((list) => {
      const exists = list.some((r) => r.section_key === key);
      if (!exists) return [...list, { ...get(key), ...next }];
      return list.map((r) => (r.section_key === key ? { ...r, ...next } : r));
    });
  }

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");
    try {
      const supabase = createBrowserSupabase();
      for (const key of KEYS) {
        const row = get(key);
        const payload = {
          section_key: key,
          content_en: row.content_en,
          content_bm: row.content_bm,
          content_zh: row.content_zh,
          images: row.images ?? [],
        };
        const { error: uErr } = await supabase.from("site_content").upsert(payload, { onConflict: "section_key" });
        if (uErr) throw uErr;
      }
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Save failed");
    } finally {
      setSaving(false);
    }
  }

  async function addGallery(file?: File) {
    if (!file) return;
    const supabase = createBrowserSupabase();
    const url = await uploadPublicFile(supabase, "gallery", file);
    const gallery = get("gallery");
    patch("gallery", { images: [...(gallery.images ?? []), url] });
  }

  const gallery = get("gallery");

  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-4xl px-4 py-8">
        <h1 className="mb-6 text-2xl font-bold">Content & gallery</h1>
        <form onSubmit={onSubmit} className="space-y-6">
          {KEYS.filter((k) => k !== "gallery").map((key) => {
            const row = get(key);
            const multiline = key === "about" || key.includes("hero") || key === "address" || key === "hours";
            return (
              <fieldset key={key} className="rounded-2xl border border-white/10 p-4">
                <legend className="px-1 text-sm font-semibold text-red-400">{key}</legend>
                <div className="mt-3 grid gap-3">
                  <LangField
                    label="EN"
                    value={row.content_en}
                    multiline={multiline}
                    onChange={(v) => patch(key, { content_en: v })}
                  />
                  <LangField
                    label="BM"
                    value={row.content_bm}
                    multiline={multiline}
                    onChange={(v) => patch(key, { content_bm: v })}
                  />
                  <LangField
                    label="中文"
                    value={row.content_zh}
                    multiline={multiline}
                    onChange={(v) => patch(key, { content_zh: v })}
                  />
                </div>
              </fieldset>
            );
          })}
          <fieldset className="rounded-2xl border border-white/10 p-4">
            <legend className="px-1 text-sm font-semibold text-red-400">gallery</legend>
            <input type="file" accept="image/*" className="mt-3 text-sm" onChange={(e) => void addGallery(e.target.files?.[0])} />
            <div className="mt-4 grid grid-cols-2 gap-3 md:grid-cols-3">
              {(gallery.images ?? []).map((url) => (
                <div key={url} className="relative">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={url} alt="" className="h-32 w-full rounded-xl object-cover" />
                  <button
                    type="button"
                    className="absolute right-2 top-2 rounded bg-black/70 px-2 py-1 text-xs"
                    onClick={() => patch("gallery", { images: gallery.images.filter((u) => u !== url) })}
                  >
                    Remove
                  </button>
                </div>
              ))}
            </div>
          </fieldset>
          {error ? <p className="text-sm text-red-400">{error}</p> : null}
          <button type="submit" disabled={saving} className="rounded-xl bg-red-600 px-5 py-2 font-semibold disabled:opacity-50">
            {saving ? "Saving..." : "Save content"}
          </button>
        </form>
      </div>
    </>
  );
}

function LangField({
  label,
  value,
  onChange,
  multiline,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  multiline?: boolean;
}) {
  return (
    <label className="block text-sm">
      {label}
      {multiline ? (
        <textarea
          value={value}
          onChange={(e) => onChange(e.target.value)}
          rows={4}
          className="mt-1 w-full rounded-lg border border-white/10 bg-zinc-900 px-3 py-2"
        />
      ) : (
        <input
          value={value}
          onChange={(e) => onChange(e.target.value)}
          className="mt-1 w-full rounded-lg border border-white/10 bg-zinc-900 px-3 py-2"
        />
      )}
    </label>
  );
}
