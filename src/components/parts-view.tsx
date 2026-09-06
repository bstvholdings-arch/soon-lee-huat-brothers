"use client";

import { PartsCatalog } from "@/components/parts-catalog";
import { useLocale } from "@/components/locale-provider";
import type { Part } from "@/lib/types";

export function PartsView({ parts, whatsapp }: { parts: Part[]; whatsapp: string }) {
  const { t } = useLocale();
  return (
    <div>
      <h1 className="mb-6 text-3xl font-bold text-white">{t("partsTitle")}</h1>
      <PartsCatalog parts={parts} whatsapp={whatsapp} />
    </div>
  );
}
