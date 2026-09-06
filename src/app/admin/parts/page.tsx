"use client";

import { FormEvent, useEffect, useState } from "react";
import { AdminNav } from "@/components/admin/admin-nav";
import { createBrowserSupabase } from "@/lib/supabase/client";
import { uploadPublicFile } from "@/lib/upload";
import type { Part, PartStock } from "@/lib/types";

const empty: Omit<Part, "id" | "created_at"> = {
  name_en: "",
  name_bm: "",
  name_zh: "",
  category: "",
  applicable_model: "",
  price: 0,
  image_url: "",
  stock_status: "in_stock",
  sku: "",
  stock_quantity: 0,
};

export default function AdminPartsPage() {
  const [rows, setRows] = useState<Part[]>([]);
  const [form, setForm] = useState(empty);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [file, setFile] = useState<File | undefined>();
  const [error, setError] = useState("");

  async function load() {
    const supabase = createBrowserSupabase();
    const { data, error: qErr } = await supabase.from("parts").select("*").order("created_at", { ascending: false });
    if (qErr) setError(qErr.message);
    else setRows((data ?? []) as Part[]);
  }

  useEffect(() => {
    void load();
  }, []);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError("");
    try {
      const supabase = createBrowserSupabase();
      let image_url = form.image_url;
      if (file) image_url = await uploadPublicFile(supabase, "part-images", file);
      const payload = { ...form, image_url, price: Number(form.price) };
      if (editingId) {
        const { error: uErr } = await supabase.from("parts").update(payload).eq("id", editingId);
        if (uErr) throw uErr;
      } else {
        const { error: iErr } = await supabase.from("parts").insert(payload);
        if (iErr) throw iErr;
      }
      setForm(empty);
      setEditingId(null);
      setFile(undefined);
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Save failed");
    }
  }

  async function remove(id: string) {
    if (!confirm("Delete this part?")) return;
    const supabase = createBrowserSupabase();
    await supabase.from("parts").delete().eq("id", id);
    await load();
  }

  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-6xl px-4 py-8">
        <h1 className="mb-6 text-2xl font-bold">Parts</h1>
        <form onSubmit={onSubmit} className="mb-8 grid gap-3 rounded-2xl border border-white/10 p-4 md:grid-cols-2">
          <Input label="Name EN" value={form.name_en} onChange={(v) => setForm({ ...form, name_en: v })} />
          <Input label="Name BM" value={form.name_bm} onChange={(v) => setForm({ ...form, name_bm: v })} />
          <Input label="Name 中文" value={form.name_zh} onChange={(v) => setForm({ ...form, name_zh: v })} />
          <Input label="Category" value={form.category} onChange={(v) => setForm({ ...form, category: v })} />
          <Input label="SKU" value={form.sku} onChange={(v) => setForm({ ...form, sku: v })} placeholder="e.g. PRT-HELMET-01" />
          <Input label="Stock quantity" type="number" value={String(form.stock_quantity)} onChange={(v) => setForm({ ...form, stock_quantity: Number(v) })} />
          <Input
            label="Applicable model"
            value={form.applicable_model}
            onChange={(v) => setForm({ ...form, applicable_model: v })}
          />
          <Input label="Price" type="number" value={String(form.price)} onChange={(v) => setForm({ ...form, price: Number(v) })} />
          <label className="block text-sm">
            Stock
            <select
              value={form.stock_status}
              onChange={(e) => setForm({ ...form, stock_status: e.target.value as PartStock })}
              className="mt-1 w-full rounded-lg border border-white/10 bg-zinc-900 px-3 py-2"
            >
              <option value="in_stock">in_stock</option>
              <option value="low">low</option>
              <option value="out">out</option>
            </select>
          </label>
          <label className="block text-sm">
            Image
            <input type="file" accept="image/*" className="mt-1 block w-full text-sm" onChange={(e) => setFile(e.target.files?.[0])} />
          </label>
          {error ? <p className="text-sm text-red-400 md:col-span-2">{error}</p> : null}
          <button type="submit" className="rounded-xl bg-red-600 px-4 py-2 font-semibold md:col-span-2">
            {editingId ? "Update part" : "Add part"}
          </button>
        </form>
        <div className="space-y-3">
          {rows.map((row) => (
            <div key={row.id} className="flex items-center justify-between rounded-xl border border-white/10 px-4 py-3">
              <div>
                <p className="font-medium">{row.name_en}</p>
                <p className="text-sm text-zinc-400">
                  {row.category} · RM {row.price}
                </p>
              </div>
              <div className="flex gap-3 text-sm">
                <button
                  type="button"
                  className="text-red-400"
                  onClick={() => {
                    setEditingId(row.id);
                    setForm({
                      name_en: row.name_en,
                      name_bm: row.name_bm,
                      name_zh: row.name_zh,
                      category: row.category,
                      applicable_model: row.applicable_model,
                      price: Number(row.price),
                      image_url: row.image_url,
                      stock_status: row.stock_status,
                      sku: row.sku ?? "",
                      stock_quantity: Number(row.stock_quantity ?? 0),
                    });
                  }}
                >
                  Edit
                </button>
                <button type="button" className="text-zinc-400" onClick={() => remove(row.id)}>
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

function Input({
  label,
  value,
  onChange,
  type = "text",
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  type?: string;
}) {
  return (
    <label className="block text-sm">
      {label}
      <input
        type={type}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="mt-1 w-full rounded-lg border border-white/10 bg-zinc-900 px-3 py-2"
      />
    </label>
  );
}
