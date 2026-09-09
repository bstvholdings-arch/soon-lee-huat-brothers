"use client";

import { useMemo, useState } from "react";
import type { Motorcycle, VehicleImage } from "@/lib/types";
import { bikeTitle, colorName, formatMYR, whatsappLink } from "@/lib/i18n";
import { useLocale } from "./locale-provider";
import { useLoan } from "./loan-modal";

const ANGLES: VehicleImage["angle_type"][] = ["main", "exhaust", "caliper", "dashboard"];

export function MotorcycleDetail({ bike, whatsapp }: { bike: Motorcycle; whatsapp: string }) {
  const { locale, t } = useLocale();
  const { openLoan } = useLoan();
  const images = bike.vehicle_images ?? [];
  const colors = useMemo(() => {
    const map = new Map<string, VehicleImage[]>();
    for (const img of images) {
      const key = `${img.color_hex}|${img.color_name_en}`;
      map.set(key, [...(map.get(key) ?? []), img]);
    }
    return [...map.entries()].map(([key, imgs]) => ({
      key,
      hex: imgs[0].color_hex,
      name: colorName(imgs[0], locale),
      images: imgs,
    }));
  }, [images, locale]);

  const [colorKey, setColorKey] = useState(colors[0]?.key ?? "");
  const [angle, setAngle] = useState<VehicleImage["angle_type"]>("main");
  const selected = colors.find((c) => c.key === colorKey) ?? colors[0];
  const current =
    selected?.images.find((img) => img.angle_type === angle) ??
    selected?.images.find((img) => img.is_main) ??
    selected?.images[0];
  const title = bikeTitle(bike, locale);
  const specs = bike.specs ?? {};

  return (
    <div className="grid gap-8 lg:grid-cols-2">
      <div>
        <div className="aspect-[4/3] overflow-hidden rounded-2xl bg-zinc-100">
          {current?.image_url ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={current.image_url} alt={title} className="h-full w-full object-cover" />
          ) : (
            <div className="flex h-full items-center justify-center text-zinc-500">—</div>
          )}
        </div>
        {colors.length > 1 ? (
          <div className="mt-4">
            <p className="mb-2 text-sm font-medium text-zinc-600">{t("colors")}</p>
            <div className="flex flex-wrap gap-2">
              {colors.map((color) => (
                <button
                  key={color.key}
                  type="button"
                  onClick={() => {
                    setColorKey(color.key);
                    setAngle("main");
                  }}
                  className={`flex items-center gap-2 rounded-full border px-3 py-1.5 text-sm ${
                    color.key === selected?.key ? "border-zinc-900 bg-zinc-100" : "border-zinc-200"
                  }`}
                >
                  <span
                    className="h-4 w-4 rounded-full ring-1 ring-zinc-300"
                    style={{ backgroundColor: color.hex || "#111" }}
                  />
                  {color.name}
                </button>
              ))}
            </div>
          </div>
        ) : null}
        {selected && selected.images.length > 1 ? (
          <div className="mt-4">
            <p className="mb-2 text-sm font-medium text-zinc-600">{t("angles")}</p>
            <div className="flex flex-wrap gap-2">
              {ANGLES.filter((a) => selected.images.some((img) => img.angle_type === a)).map((a) => (
                <button
                  key={a}
                  type="button"
                  onClick={() => setAngle(a)}
                  className={`rounded-lg px-3 py-1.5 text-xs capitalize ${
                    angle === a ? "bg-zinc-900 text-white" : "bg-zinc-100 text-zinc-700"
                  }`}
                >
                  {a}
                </button>
              ))}
            </div>
          </div>
        ) : null}
      </div>
      <div>
        <p className="text-sm uppercase tracking-wide text-zinc-500">
          {bike.type === "used" ? t("usedBikes") : t("newBikes")}
        </p>
        <h1 className="mt-1 text-3xl font-bold text-zinc-900">{title}</h1>
        <p className="mt-2 text-xs font-medium text-zinc-500">{t("priceFrom")}</p>
        <p className="text-3xl font-semibold text-zinc-900">{formatMYR(Number(bike.price))}</p>
        <p className="text-sm text-zinc-500">{t("cashPrice")}</p>
        <dl className="mt-6 grid grid-cols-2 gap-3 text-sm">
          {bike.year ? (
            <Spec label={t("year")} value={String(bike.year)} />
          ) : null}
          {bike.mileage != null ? (
            <Spec label={t("mileage")} value={`${bike.mileage.toLocaleString()} ${t("km")}`} />
          ) : null}
          {specs.cc ? <Spec label={t("cc")} value={specs.cc} /> : null}
          {specs.engine ? <Spec label={t("engine")} value={specs.engine} /> : null}
          {specs.fuel ? <Spec label={t("fuel")} value={specs.fuel} /> : null}
          {specs.engine_type ? <Spec label={t("engineType")} value={specs.engine_type} /> : null}
          {specs.cylinder_arrangement ? <Spec label={t("cylinderArrangement")} value={specs.cylinder_arrangement} /> : null}
          {specs.bore_x_stroke ? <Spec label={t("boreStroke")} value={specs.bore_x_stroke} /> : null}
          {specs.compression ? <Spec label={t("compression")} value={specs.compression} /> : null}
          {specs.maximum_power ? <Spec label={t("maximumPower")} value={specs.maximum_power} /> : null}
          {specs.maximum_torque ? <Spec label={t("maximumTorque")} value={specs.maximum_torque} /> : null}
          {specs.ignition_system ? <Spec label={t("ignitionSystem")} value={specs.ignition_system} /> : null}
          {specs.lubrication ? <Spec label={t("lubrication")} value={specs.lubrication} /> : null}
          {specs.engine_oil_volume ? <Spec label={t("engineOilVolume")} value={specs.engine_oil_volume} /> : null}
          {specs.fuel_tank_capacity ? <Spec label={t("fuelTankCapacity")} value={specs.fuel_tank_capacity} /> : null}
          {specs.fuel_system ? <Spec label={t("fuelSystem")} value={specs.fuel_system} /> : null}
          {specs.ignition ? <Spec label={t("ignition")} value={specs.ignition} /> : null}
          {specs.battery_type ? <Spec label={t("batteryType")} value={specs.battery_type} /> : null}
        </dl>
        {specs.notes ? <p className="mt-4 text-sm text-zinc-600">{specs.notes}</p> : null}
        <div className="mt-8 grid gap-3">
          <button
            type="button"
            onClick={() => openLoan({ price: Number(bike.price), name: title })}
            className="rounded-xl bg-zinc-900 py-3 font-semibold text-white hover:bg-zinc-700"
          >
            {t("loanCta")}
          </button>
          <a
            href={whatsappLink(whatsapp, t("inquireBike", { name: title }))}
            target="_blank"
            rel="noreferrer"
            className="rounded-xl bg-emerald-500 py-3 text-center font-semibold text-black hover:bg-emerald-400"
          >
            {t("waInquiry")}
          </a>
          <a
            href={whatsappLink(whatsapp, t("visitWa", { name: title }))}
            target="_blank"
            rel="noreferrer"
            className="rounded-xl border border-zinc-300 py-3 text-center font-semibold text-zinc-800 hover:bg-zinc-100"
          >
            {t("bookVisit")}
          </a>
        </div>
      </div>
    </div>
  );
}

function Spec({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl bg-zinc-50 p-3">
      <dt className="text-zinc-500">{label}</dt>
      <dd className="mt-1 font-medium text-zinc-900">{value}</dd>
    </div>
  );
}
