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
  return (
    <div>
      <HomeHero
        companyName={company}
        companyReg={companyReg}
        tagline={contentText(content, "hero_tagline", locale)}
        subtitle={contentText(content, "hero_subtitle", locale)}
        phone={contentText(content, "phone", locale)}
        whatsapp={whatsapp}
      />
      <div className="mt-10">
        <BikeGrid bikes={bikes} whatsapp={whatsapp} title={t("newBikes")} />
      </div>
      <BrandShowcase brands={brands} />
    </div>
  );
}
