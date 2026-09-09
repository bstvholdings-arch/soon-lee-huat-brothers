"use client";

import type { Brand } from "@/lib/types";
import { useLocale } from "./locale-provider";

export function BrandShowcase({ brands }: { brands: Brand[] }) {
  const { t } = useLocale();
  return (
    <section className="mt-12">
      <h2 className="mb-4 text-xl font-semibold text-zinc-900">{t("brands")}</h2>
      {brands.length === 0 ? (
        <p className="text-sm text-zinc-500">{t("emptyBrands")}</p>
      ) : (
        <div className="flex gap-4 overflow-x-auto pb-2 md:grid md:grid-cols-6 md:overflow-visible">
          {brands.map((brand) => (
            <div
              key={brand.id}
              className="flex min-w-[140px] items-center justify-center rounded-2xl border border-zinc-200 bg-white p-4 md:min-w-0"
            >
              {brand.logo_url ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={brand.logo_url} alt={brand.brand_name} className="h-12 w-full object-contain" />
              ) : (
                <span className="text-sm font-semibold text-zinc-800">{brand.brand_name}</span>
              )}
            </div>
          ))}
        </div>
      )}
    </section>
  );
}
