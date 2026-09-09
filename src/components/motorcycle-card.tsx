"use client";

import Link from "next/link";
import type { Motorcycle } from "@/lib/types";
import { bikeTitle, formatMYR, mainImage, whatsappLink } from "@/lib/i18n";
import { useLocale } from "./locale-provider";

export function MotorcycleCard({
  bike,
  whatsapp,
}: {
  bike: Motorcycle;
  whatsapp: string;
}) {
  const { locale, t } = useLocale();
  const title = bikeTitle(bike, locale);
  const image = mainImage(bike);
  const specs = bike.specs ?? {};
  const tags = [specs.cc, specs.engine, specs.fuel].filter(Boolean) as string[];
  if (bike.year) tags.unshift(String(bike.year));
  if (bike.mileage != null) tags.push(`${bike.mileage.toLocaleString()} ${t("km")}`);

  return (
    <article className="overflow-hidden rounded-2xl border border-zinc-200 bg-white shadow-sm">
      <div className="relative aspect-[4/3] bg-zinc-100">
        {image?.image_url ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={image.image_url} alt={title} className="h-full w-full object-cover" />
        ) : (
          <div className="flex h-full items-center justify-center text-sm text-zinc-500">—</div>
        )}
        {bike.status === "sold" ? (
          <span className="absolute left-3 top-3 rounded-full bg-zinc-900 px-3 py-1 text-xs font-semibold uppercase text-white">
            {t("sold")}
          </span>
        ) : null}
      </div>
      <div className="space-y-3 p-4">
        <div>
          <h3 className="text-lg font-semibold text-zinc-900">{title}</h3>
          <p className="text-xs font-medium text-zinc-500">{t("priceFrom")}</p>
          <p className="text-xl font-bold text-zinc-900">{formatMYR(Number(bike.price))}</p>
        </div>
        {tags.length ? (
          <div className="flex flex-wrap gap-1.5">
            {tags.map((tag) => (
              <span key={tag} className="rounded-full bg-zinc-100 px-2 py-0.5 text-xs text-zinc-600">
                {tag}
              </span>
            ))}
          </div>
        ) : null}
        <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
          <Link
            href={`/motorcycles/${bike.id}`}
            className="rounded-xl bg-zinc-900 px-3 py-2 text-center text-sm font-semibold text-white hover:bg-zinc-700"
          >
            {t("viewDetails")}
          </Link>
          <a
            href={whatsappLink(whatsapp, t("inquireBike", { name: title }))}
            target="_blank"
            rel="noreferrer"
            className="rounded-xl bg-zinc-100 px-3 py-2 text-center text-sm font-semibold text-zinc-700"
          >
            {t("waInquiry")}
          </a>
        </div>
      </div>
    </article>
  );
}
