"use client";

import { useMemo, useState } from "react";
import type { Part } from "@/lib/types";
import { formatMYR, partName, whatsappLink } from "@/lib/i18n";
import { useLocale } from "./locale-provider";

export function PartsCatalog({ parts, whatsapp }: { parts: Part[]; whatsapp: string }) {
  const { locale, t } = useLocale();
  const [q, setQ] = useState("");
  const [category, setCategory] = useState("all");
  const categories = useMemo(
    () => ["all", ...Array.from(new Set(parts.map((p) => p.category).filter(Boolean)))],
    [parts],
  );
  const filtered = parts.filter((part) => {
    const name = partName(part, locale).toLowerCase();
    const hay = `${name} ${part.applicable_model} ${part.category}`.toLowerCase();
    const matchQ = !q || hay.includes(q.toLowerCase());
    const matchC = category === "all" || part.category === category;
    return matchQ && matchC;
  });

  const stockLabel = (status: Part["stock_status"]) =>
    status === "out" ? t("outStock") : status === "low" ? t("lowStock") : t("inStock");

  return (
    <div>
      <div className="mb-6 grid gap-3 sm:grid-cols-2">
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder={t("search")}
          className="rounded-xl border border-zinc-200 bg-white px-4 py-3 text-zinc-900 outline-none focus:border-zinc-900"
        />
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="rounded-xl border border-zinc-200 bg-white px-4 py-3 text-zinc-900"
        >
          {categories.map((c) => (
            <option key={c} value={c}>
              {c === "all" ? t("allCategories") : c}
            </option>
          ))}
        </select>
      </div>
      {filtered.length === 0 ? (
        <p className="text-zinc-500">{t("emptyParts")}</p>
      ) : (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
          {filtered.map((part) => {
            const name = partName(part, locale);
            return (
              <article key={part.id} className="overflow-hidden rounded-2xl border border-zinc-200 bg-white">
                <div className="aspect-square bg-zinc-100">
                  {part.image_url ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={part.image_url} alt={name} className="h-full w-full object-cover" />
                  ) : (
                    <div className="flex h-full items-center justify-center text-zinc-500">—</div>
                  )}
                </div>
                <div className="space-y-2 p-4">
                  <p className="text-xs uppercase tracking-wide text-zinc-500">{part.category}</p>
                  <h3 className="font-semibold text-zinc-900">{name}</h3>
                  {part.applicable_model ? (
                    <p className="text-sm text-zinc-500">
                      {t("applicable")}: {part.applicable_model}
                    </p>
                  ) : null}
                  <p className="text-xs font-medium text-zinc-500">{t("priceFrom")}</p>
                  <p className="text-lg font-bold text-zinc-900">{formatMYR(Number(part.price))}</p>
                  <p className="text-xs text-zinc-500">{stockLabel(part.stock_status)}</p>
                  <a
                    href={whatsappLink(whatsapp, t("inquirePart", { name }))}
                    target="_blank"
                    rel="noreferrer"
                    className="mt-2 block rounded-xl bg-emerald-500 py-2 text-center text-sm font-semibold text-black"
                  >
                    {t("waInquiry")}
                  </a>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </div>
  );
}
