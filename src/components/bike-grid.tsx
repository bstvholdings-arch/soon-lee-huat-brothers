"use client";

import type { Motorcycle } from "@/lib/types";
import { MotorcycleCard } from "./motorcycle-card";
import { useLocale } from "./locale-provider";

export function BikeGrid({
  bikes,
  whatsapp,
  title,
  intro,
}: {
  bikes: Motorcycle[];
  whatsapp: string;
  title: string;
  intro?: string;
}) {
  const { t } = useLocale();
  return (
    <section>
      <h2 className="text-2xl font-bold text-zinc-900">{title}</h2>
      {intro ? <p className="mt-2 text-zinc-500">{intro}</p> : null}
      {bikes.length === 0 ? (
        <p className="mt-6 text-zinc-500">{t("emptyBikes")}</p>
      ) : (
        <div className="mt-6 grid grid-cols-1 gap-4 md:grid-cols-3">
          {bikes.map((bike) => (
            <MotorcycleCard key={bike.id} bike={bike} whatsapp={whatsapp} />
          ))}
        </div>
      )}
    </section>
  );
}
