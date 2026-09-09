"use client";

import { BrandShowcase } from "@/components/brand-showcase";
import { BikeGrid } from "@/components/bike-grid";
import { HomeHero } from "@/components/home-hero";
import { contentText } from "@/lib/i18n";
import type { Brand, ContentMap, Motorcycle } from "@/lib/types";
import { useLocale } from "@/components/locale-provider";

export function HomeView({
  content,
  bikes,
  brands,
  whatsapp,
}: {
  content: ContentMap;
  bikes: Motorcycle[];
  brands: Brand[];
  whatsapp: string;
}) {
  const { locale, t } = useLocale();
  const company = contentText(
    content,
    "company_name",
    locale,
    "Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.",
  );
  const companyReg = contentText(content, "company_reg", locale);
  const heroImage = content["hero_image"]?.images?.[0];
  return (
    <div>
      {/* reserved hero photo slot (same size as the original hero block) */}
      <div className="flex min-h-[320px] items-center justify-center overflow-hidden rounded-3xl border border-zinc-200 bg-zinc-50 sm:min-h-[420px]">
        {heroImage ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={heroImage} alt="" className="h-full w-full object-cover" />
        ) : (
          <span className="text-sm text-zinc-400">Hero photo</span>
        )}
      </div>
      <div className="mt-10">
        <HomeHero
          companyName={company}
          companyReg={companyReg}
          tagline={contentText(content, "hero_tagline", locale)}
          subtitle={contentText(content, "hero_subtitle", locale)}
          phone={contentText(content, "phone", locale)}
          whatsapp={whatsapp}
        />
      </div>
      <div className="mt-10">
        <BikeGrid bikes={bikes} whatsapp={whatsapp} title={t("newBikes")} />
      </div>
      <BrandShowcase brands={brands} />
    </div>
  );
}
