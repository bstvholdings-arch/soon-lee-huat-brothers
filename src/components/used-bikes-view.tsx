"use client";

import { BikeGrid } from "@/components/bike-grid";
import { useLocale } from "@/components/locale-provider";
import type { Motorcycle } from "@/lib/types";

export function UsedBikesView({ bikes, whatsapp }: { bikes: Motorcycle[]; whatsapp: string }) {
  const { t } = useLocale();
  return <BikeGrid bikes={bikes} whatsapp={whatsapp} title={t("usedBikes")} intro={t("usedIntro")} />;
}
