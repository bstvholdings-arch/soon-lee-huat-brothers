"use client";

import { FormEvent, useEffect, useState } from "react";
import { AdminNav } from "@/components/admin/admin-nav";
import { createBrowserSupabase } from "@/lib/supabase/client";
import { uploadPublicFile } from "@/lib/upload";
import type { Brand } from "@/lib/types";

export default function AdminBrandsPage() {
  const [rows, setRows] = useState<Brand[]>([]);
  const [brand_name, setName] = useState("");
  const [display_order, setOrder] = useState(0);
  const [file, setFile] = useState<File | undefined>();
  const [editingId, setEditingId] = useState<string | null>(null);
  const [logo_url, setLogo] = useState("");
  const [error, setError] = useState("");

  async function load() {
    const supabase = createBrowserSupabase();
    const { data, error: qErr } = await supabase.from("brands").select("*").order("display_order");
    if (qErr) setError(qErr.message);
    else setRows((data ?? []) as Brand[]);
  }

  useEffect(() => {
    void load();
  }, []);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError("");
    try {
      const supabase = createBrowserSupabase();
      let url = logo_url;
      if (file) url = await uploadPublicFile(supabase, "brand-logos", file);
      const payload = { brand_name, logo_url: url, display_order: Number(display_order) };
      if (editingId) {
        const { error: uErr } = await supabase.from("brands").update(payload).eq("id", editingId);
        if (uErr) throw uErr;
      } else {
        const { error: iErr } = await supabase.from("brands").insert(payload);
        if (iErr) throw iErr;
      }
      setName("");
      setOrder(rows.length + 1);
      setFile(undefined);
      setLogo("");
      setEditingId(null);
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Save failed");
    }
  }

  async function remove(id: string) {
    if (!confirm("Delete this brand?")) return;
    const supabase = createBrowserSupabase();
    await supabase.from("brands").delete().eq("id", id);
    await load();
  }

  async function move(id: string, dir: -1 | 1) {
    const index = rows.findIndex((r) => r.id === id);
    const swap = rows[index + dir];
    if (!swap) return;
    const supabase = createBrowserSupabase();
    await Promise.all([
      supabase.from("brands").update({ display_order: swap.display_order }).eq("id", id),
      supabase.from("brands").update({ display_order: rows[index].display_order }).eq("id", swap.id),
    ]);
    await load();
  }

  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-4xl px-4 py-8">
        <h1 className="mb-6 text-2xl font-bold">Brands</h1>
        <form onSubmit={onSubmit} className="mb-8 grid gap-3 rounded-2xl border border-zinc-200 bg-white p-4">
          <label className="text-sm">
            Brand name
            <input
              value={brand_name}
              onChange={(e) => setName(e.target.value)}
              required
              className="mt-1 w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-zinc-900"
            />
          </label>
          <label className="text-sm">
            Display order
            <input
              type="number"
              value={display_order}
              onChange={(e) => setOrder(Number(e.target.value))}
              className="mt-1 w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-zinc-900"
            />
          </label>
          <label className="text-sm">
            Logo
            <input type="file" accept="image/*" className="mt-1 block w-full text-sm" onChange={(e) => setFile(e.target.files?.[0])} />
          </label>
          {error ? <p className="text-sm text-red-500">{error}</p> : null}
          <button type="submit" className="rounded-xl bg-zinc-900 px-4 py-2 font-semibold text-white">
            {editingId ? "Update brand" : "Add brand"}
          </button>
        </form>
        <div className="space-y-3">
          {rows.map((row) => (
            <div key={row.id} className="flex items-center justify-between gap-3 rounded-xl border border-zinc-200 bg-white px-4 py-3">
              <div className="flex items-center gap-3">
                {row.logo_url ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={row.logo_url} alt="" className="h-8 w-16 object-contain" />
                ) : null}
                <p>{row.brand_name}</p>
              </div>
              <div className="flex gap-2 text-sm">
                <button type="button" onClick={() => move(row.id, -1)}>
                  Up
                </button>
                <button type="button" onClick={() => move(row.id, 1)}>
                  Down
                </button>
                <button
                  type="button"
                  className="text-zinc-700 hover:underline"
                  onClick={() => {
                    setEditingId(row.id);
                    setName(row.brand_name);
                    setOrder(row.display_order);
                    setLogo(row.logo_url);
                  }}
                >
                  Edit
                </button>
                <button type="button" className="text-zinc-500 hover:text-red-600" onClick={() => remove(row.id)}>
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </>
  );
}
