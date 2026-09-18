"use client";

import { BikeGrid } from "@/components/bike-grid";
import { useLocale } from "@/components/locale-provider";
import { contentText } from "@/lib/i18n";
import type { ContentMap, Motorcycle } from "@/lib/types";

export function UsedBikesView({ content, bikes }: { content: ContentMap; bikes: Motorcycle[] }) {
  const { t } = useLocale();
  const usedHero = content["used_hero"]?.images?.[0];
  const whatsapp = contentText(content, "whatsapp", "en") || contentText(content, "phone", "en");
  return (
    <div>
      {/* hero photo slot — 80vw wide, 150vh tall (3/2 screen), filled */}
      <div className="relative left-1/2 -translate-x-1/2 flex w-[80vw] h-[150vh] items-center justify-center overflow-hidden rounded-3xl border border-zinc-200 bg-zinc-50">
        {usedHero ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={usedHero} alt="" className="h-full w-full object-cover" />
        ) : (
          <span className="text-sm text-zinc-500">Used bikes hero photo</span>
        )}
      </div>
      <div className="mt-10">
        <BikeGrid bikes={bikes} whatsapp={whatsapp} title={t("usedBikes")} intro={t("usedIntro")} />
      </div>
    </div>
  );
}
