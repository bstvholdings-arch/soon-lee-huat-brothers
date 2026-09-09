"use client";

import { FormEvent, useEffect, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { AdminNav } from "@/components/admin/admin-nav";
import { useLocale } from "@/components/locale-provider";
import { createBrowserSupabase } from "@/lib/supabase/client";
import { uploadPublicFile } from "@/lib/upload";
import type { AngleType, Motorcycle, MotorcycleType, StockStatus, VehicleImage } from "@/lib/types";

type ImageDraft = {
  localId: string;
  id?: string;
  color_name_en: string;
  color_name_bm: string;
  color_name_zh: string;
  color_hex: string;
  image_url: string;
  is_main: boolean;
  angle_type: AngleType;
  file?: File;
};

function emptyImage(): ImageDraft {
  return {
    localId: crypto.randomUUID(),
    color_name_en: "",
    color_name_bm: "",
    color_name_zh: "",
    color_hex: "#111111",
    image_url: "",
    is_main: false,
    angle_type: "main",
  };
}

function fromDb(img: VehicleImage): ImageDraft {
  return {
    localId: img.id,
    id: img.id,
    color_name_en: img.color_name_en,
    color_name_bm: img.color_name_bm,
    color_name_zh: img.color_name_zh,
    color_hex: img.color_hex,
    image_url: img.image_url,
    is_main: img.is_main,
    angle_type: img.angle_type,
  };
}

export function MotorcycleEditor({ initial }: { initial?: Motorcycle }) {
  const router = useRouter();
  const { t } = useLocale();
  const [type, setType] = useState<MotorcycleType>(initial?.type ?? "new");
  const [title_en, setTitleEn] = useState(initial?.title_en ?? "");
  const [title_bm, setTitleBm] = useState(initial?.title_bm ?? "");
  const [title_zh, setTitleZh] = useState(initial?.title_zh ?? "");
  const [price, setPrice] = useState(Number(initial?.price ?? 0));
  const [year, setYear] = useState(initial?.year ? String(initial.year) : "");
  const [mileage, setMileage] = useState(initial?.mileage != null ? String(initial.mileage) : "");
  const [cc, setCc] = useState(initial?.specs?.cc ?? "");
  const [engine, setEngine] = useState(initial?.specs?.engine ?? "");
  const [fuel, setFuel] = useState(initial?.specs?.fuel ?? "");
  const [notes, setNotes] = useState(initial?.specs?.notes ?? "");
  const [engineType, setEngineType] = useState(initial?.specs?.engine_type ?? "");
  const [cylinderArr, setCylinderArr] = useState(initial?.specs?.cylinder_arrangement ?? "");
  const [boreStroke, setBoreStroke] = useState(initial?.specs?.bore_x_stroke ?? "");
  const [compression, setCompression] = useState(initial?.specs?.compression ?? "");
  const [maxPower, setMaxPower] = useState(initial?.specs?.maximum_power ?? "");
  const [maxTorque, setMaxTorque] = useState(initial?.specs?.maximum_torque ?? "");
  const [ignitionSystem, setIgnitionSystem] = useState(initial?.specs?.ignition_system ?? "");
  const [lubrication, setLubrication] = useState(initial?.specs?.lubrication ?? "");
  const [oilVolume, setOilVolume] = useState(initial?.specs?.engine_oil_volume ?? "");
  const [tankCapacity, setTankCapacity] = useState(initial?.specs?.fuel_tank_capacity ?? "");
  const [fuelSystem, setFuelSystem] = useState(initial?.specs?.fuel_system ?? "");
  const [ignition, setIgnition] = useState(initial?.specs?.ignition ?? "");
  const [batteryType, setBatteryType] = useState(initial?.specs?.battery_type ?? "");
  const [status, setStatus] = useState<StockStatus>(initial?.status ?? "available");
  const [sku, setSku] = useState(initial?.sku ?? "");
  const [stockQuantity, setStockQuantity] = useState(Number(initial?.stock_quantity ?? 0));
  const [images, setImages] = useState<ImageDraft[]>(
    initial?.vehicle_images?.length ? initial.vehicle_images.map(fromDb) : [emptyImage()],
  );
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError("");
    try {
      const supabase = createBrowserSupabase();
      const payload = {
        type,
        title_en,
        title_bm,
        title_zh,
        price,
        year: year ? Number(year) : null,
        mileage: mileage ? Number(mileage) : null,
        specs: {
          cc,
          engine,
          fuel,
          notes,
          engine_type: engineType,
          cylinder_arrangement: cylinderArr,
          bore_x_stroke: boreStroke,
          compression,
          maximum_power: maxPower,
          maximum_torque: maxTorque,
          ignition_system: ignitionSystem,
          lubrication,
          engine_oil_volume: oilVolume,
          fuel_tank_capacity: tankCapacity,
          fuel_system: fuelSystem,
          ignition,
          battery_type: batteryType,
        },
        status,
        sku,
        stock_quantity: Number(stockQuantity),
      };
      let motorcycleId = initial?.id;
      if (motorcycleId) {
        const { error: upErr } = await supabase.from("motorcycles").update(payload).eq("id", motorcycleId);
        if (upErr) throw upErr;
      } else {
        const { data, error: insErr } = await supabase.from("motorcycles").insert(payload).select("id").single();
        if (insErr) throw insErr;
        motorcycleId = data.id;
      }

      const keepIds: string[] = [];
      for (const img of images) {
        let image_url = img.image_url;
        if (img.file) {
          image_url = await uploadPublicFile(supabase, "vehicle-images", img.file);
        }
        const row = {
          motorcycle_id: motorcycleId,
          color_name_en: img.color_name_en,
          color_name_bm: img.color_name_bm,
          color_name_zh: img.color_name_zh,
          color_hex: img.color_hex,
          image_url,
          is_main: img.is_main,
          angle_type: img.angle_type,
        };
        if (img.id) {
          const { error: imgErr } = await supabase.from("vehicle_images").update(row).eq("id", img.id);
          if (imgErr) throw imgErr;
          keepIds.push(img.id);
        } else if (image_url) {
          const { data, error: imgErr } = await supabase.from("vehicle_images").insert(row).select("id").single();
          if (imgErr) throw imgErr;
          keepIds.push(data.id);
        }
      }

      if (initial?.id) {
        const existing = initial.vehicle_images ?? [];
        const toDelete = existing.filter((img) => !keepIds.includes(img.id)).map((img) => img.id);
        if (toDelete.length) {
          await supabase.from("vehicle_images").delete().in("id", toDelete);
        }
      }

      router.push("/admin/motorcycles");
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Save failed");
    } finally {
      setSaving(false);
    }
  }

  return (
    <form onSubmit={onSubmit} className="space-y-6">
      <div className="grid gap-4 md:grid-cols-2">
        <Select label="Type" value={type} onChange={(v) => setType(v as MotorcycleType)} options={["new", "used"]} />
        <Select label="Status" value={status} onChange={(v) => setStatus(v as StockStatus)} options={["available", "sold"]} />
        <Field label="Title EN" value={title_en} onChange={setTitleEn} required />
        <Field label="Title BM" value={title_bm} onChange={setTitleBm} />
        <Field label="Title 中文" value={title_zh} onChange={setTitleZh} />
        <Field label="Price (RM)" value={String(price)} onChange={(v) => setPrice(Number(v))} type="number" />
        <Field label="Year" value={year} onChange={setYear} type="number" />
        <Field label="Mileage" value={mileage} onChange={setMileage} type="number" />
        <Field label="CC" value={cc} onChange={setCc} />
        <Field label="Engine" value={engine} onChange={setEngine} />
        <Field label="Fuel" value={fuel} onChange={setFuel} />
      </div>
      <h2 className="mt-2 font-semibold">{t("engineSpecs")}</h2>
      <div className="grid gap-4 md:grid-cols-2">
        <Field label={t("engineType")} value={engineType} onChange={setEngineType} />
        <Field label={t("cylinderArrangement")} value={cylinderArr} onChange={setCylinderArr} />
        <Field label={t("boreStroke")} value={boreStroke} onChange={setBoreStroke} />
        <Field label={t("compression")} value={compression} onChange={setCompression} />
        <Field label={t("maximumPower")} value={maxPower} onChange={setMaxPower} />
        <Field label={t("maximumTorque")} value={maxTorque} onChange={setMaxTorque} />
        <Field label={t("ignitionSystem")} value={ignitionSystem} onChange={setIgnitionSystem} />
        <Field label={t("lubrication")} value={lubrication} onChange={setLubrication} />
        <Field label={t("engineOilVolume")} value={oilVolume} onChange={setOilVolume} />
        <Field label={t("fuelTankCapacity")} value={tankCapacity} onChange={setTankCapacity} />
        <Field label={t("fuelSystem")} value={fuelSystem} onChange={setFuelSystem} />
        <Field label={t("ignition")} value={ignition} onChange={setIgnition} />
        <Field label={t("batteryType")} value={batteryType} onChange={setBatteryType} />
        <Field label="SKU" value={sku} onChange={setSku} placeholder="e.g. MTR-2024-001" />
        <Field label="Stock quantity" value={String(stockQuantity)} onChange={(v) => setStockQuantity(Number(v))} type="number" />
      </div>
      <label className="block text-sm">
        Condition / notes
        <textarea
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          className="mt-1 w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-zinc-900"
          rows={3}
        />
      </label>
      <div>
        <div className="mb-3 flex items-center justify-between">
          <h2 className="font-semibold">Images, colours & angles</h2>
          <button
            type="button"
            onClick={() => setImages((list) => [...list, emptyImage()])}
            className="rounded-lg bg-zinc-100 px-3 py-1.5 text-sm text-zinc-700"
          >
            Add image
          </button>
        </div>
        <div className="space-y-4">
          {images.map((img, index) => (
            <div key={img.localId} className="grid gap-3 rounded-2xl border border-zinc-200 bg-white p-4 md:grid-cols-2">
              <Field
                label="Colour EN"
                value={img.color_name_en}
                onChange={(v) => updateImage(setImages, index, { color_name_en: v })}
              />
              <Field
                label="Colour BM"
                value={img.color_name_bm}
                onChange={(v) => updateImage(setImages, index, { color_name_bm: v })}
              />
              <Field
                label="Colour 中文"
                value={img.color_name_zh}
                onChange={(v) => updateImage(setImages, index, { color_name_zh: v })}
              />
              <Field
                label="Colour hex"
                value={img.color_hex}
                onChange={(v) => updateImage(setImages, index, { color_hex: v })}
              />
              <Select
                label="Angle"
                value={img.angle_type}
                onChange={(v) => updateImage(setImages, index, { angle_type: v as AngleType })}
                options={["main", "exhaust", "caliper", "dashboard"]}
              />
              <label className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={img.is_main}
                  onChange={(e) => updateImage(setImages, index, { is_main: e.target.checked })}
                />
                Main listing image
              </label>
              <label className="block text-sm md:col-span-2">
                Photo
                <input
                  type="file"
                  accept="image/*"
                  className="mt-1 block w-full text-sm"
                  onChange={(e) => updateImage(setImages, index, { file: e.target.files?.[0] })}
                />
                {img.image_url ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={img.image_url} alt="" className="mt-2 h-24 rounded-lg object-cover" />
                ) : null}
              </label>
              <button
                type="button"
                className="text-left text-sm text-red-600 hover:underline"
                onClick={() => setImages((list) => list.filter((_, i) => i !== index))}
              >
                Remove image
              </button>
            </div>
          ))}
        </div>
      </div>
      {error ? <p className="text-sm text-red-500">{error}</p> : null}
      <button type="submit" disabled={saving} className="rounded-xl bg-zinc-900 px-5 py-2 font-semibold text-white disabled:opacity-50">
        {saving ? "Saving..." : "Save motorcycle"}
      </button>
    </form>
  );
}

function updateImage(
  setImages: React.Dispatch<React.SetStateAction<ImageDraft[]>>,
  index: number,
  patch: Partial<ImageDraft>,
) {
  setImages((list) => list.map((item, i) => (i === index ? { ...item, ...patch } : item)));
}

function Field({
  label,
  value,
  onChange,
  type = "text",
  required,
  placeholder,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  type?: string;
  required?: boolean;
  placeholder?: string;
}) {
  return (
    <label className="block text-sm">
      {label}
      <input
        type={type}
        required={required}
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="mt-1 w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-zinc-900"
      />
    </label>
  );
}

function Select({
  label,
  value,
  onChange,
  options,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  options: string[];
}) {
  return (
    <label className="block text-sm">
      {label}
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="mt-1 w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-zinc-900"
      >
        {options.map((opt) => (
          <option key={opt} value={opt}>
            {opt}
          </option>
        ))}
      </select>
    </label>
  );
}

export function MotorcycleList() {
  const [rows, setRows] = useState<Motorcycle[]>([]);
  const [error, setError] = useState("");

  async function load() {
    try {
      const supabase = createBrowserSupabase();
      const { data, error: qErr } = await supabase
        .from("motorcycles")
        .select("*, vehicle_images(*)")
        .order("created_at", { ascending: false });
      if (qErr) throw qErr;
      setRows((data ?? []) as Motorcycle[]);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Load failed");
    }
  }

  useEffect(() => {
    void load();
  }, []);

  async function remove(id: string) {
    if (!confirm("Delete this motorcycle?")) return;
    const supabase = createBrowserSupabase();
    const { error: delErr } = await supabase.from("motorcycles").delete().eq("id", id);
    if (delErr) {
      setError(delErr.message);
      return;
    }
    await load();
  }

  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-6xl px-4 py-8">
        <div className="mb-6 flex items-center justify-between">
          <h1 className="text-2xl font-bold">Motorcycles</h1>
          <Link href="/admin/motorcycles/new" className="rounded-xl bg-zinc-900 px-4 py-2 text-sm font-semibold text-white">
            Add motorcycle
          </Link>
        </div>
        {error ? <p className="mb-4 text-sm text-red-500">{error}</p> : null}
        <div className="overflow-x-auto rounded-2xl border border-zinc-200">
          <table className="w-full text-left text-sm">
            <thead className="bg-zinc-50 text-zinc-500">
              <tr>
                <th className="px-4 py-3">Title</th>
                <th className="px-4 py-3">Type</th>
                <th className="px-4 py-3">Price</th>
                <th className="px-4 py-3">Engine</th>
                <th className="px-4 py-3">Status</th>
                <th className="px-4 py-3"></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => (
                <tr key={row.id} className="border-t border-zinc-200">
                  <td className="px-4 py-3">{row.title_en}</td>
                  <td className="px-4 py-3">{row.type}</td>
                  <td className="px-4 py-3">{row.price}</td>
                  <td className="px-4 py-3">{(row.specs as { engine_type?: string } | undefined)?.engine_type ?? "—"}</td>
                  <td className="px-4 py-3">{row.status}</td>
                  <td className="px-4 py-3 text-right">
                    <Link href={`/admin/motorcycles/${row.id}`} className="mr-3 text-zinc-700 hover:underline">
                      Edit
                    </Link>
                    <button type="button" onClick={() => remove(row.id)} className="text-zinc-500 hover:text-red-600">
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}
