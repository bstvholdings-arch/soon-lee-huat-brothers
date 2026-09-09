"use client";

import { contentText, telLink, mapLink } from "@/lib/i18n";
import type { ContentMap } from "@/lib/types";
import { useLocale } from "./locale-provider";

export function AboutView({ content }: { content: ContentMap }) {
  const { locale, t } = useLocale();
  const company = contentText(content, "company_name", locale, "Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.");
  const about = contentText(content, "about", locale);
  const address = contentText(content, "address", locale);
  const hours = contentText(content, "hours", locale);
  const phone = contentText(content, "phone", locale);
  const maps = contentText(content, "maps_url", locale);
  const waze = contentText(content, "waze_url", locale);
  const gallery = content.gallery?.images ?? [];

  return (
    <div className="space-y-10">
      <section>
        <h1 className="text-3xl font-bold text-zinc-900">{t("aboutTitle")}</h1>
        <p className="mt-2 text-sm text-zinc-500">{company}</p>
        <p className="mt-4 max-w-3xl whitespace-pre-wrap text-zinc-700">{about}</p>
      </section>
      <section className="rounded-2xl border border-zinc-200 bg-white p-6">
        <h2 className="text-xl font-semibold text-zinc-900">{t("location")}</h2>
        <div className="mt-4 space-y-2 text-zinc-700">
          {address ? (
            <p>
              <a href={mapLink(address)} target="_blank" rel="noreferrer" className="text-zinc-900 hover:underline">
                {address}
              </a>
            </p>
          ) : null}
          {hours ? <p>{hours}</p> : null}
          {phone ? (
            <p>
              <a href={telLink(phone)} className="text-zinc-900 hover:underline">
                {phone}
              </a>
            </p>
          ) : null}
        </div>
        <div className="mt-4 flex flex-wrap gap-3">
          {maps ? (
            <a href={maps} target="_blank" rel="noreferrer" className="rounded-xl bg-zinc-900 px-4 py-2 text-sm font-semibold text-white">
              {t("maps")}
            </a>
          ) : null}
          {waze ? (
            <a href={waze} target="_blank" rel="noreferrer" className="rounded-xl bg-zinc-100 px-4 py-2 text-sm font-semibold text-zinc-700">
              {t("waze")}
            </a>
          ) : null}
        </div>
      </section>
      <section>
        <h2 className="mb-4 text-xl font-semibold text-zinc-900">{t("gallery")}</h2>
        {gallery.length === 0 ? (
          <p className="text-zinc-500">{t("emptyGallery")}</p>
        ) : (
          <div className="grid grid-cols-1 gap-4 md:grid-cols-3">
            {gallery.map((url) => (
              // eslint-disable-next-line @next/next/no-img-element
              <img key={url} src={url} alt="" className="h-56 w-full rounded-2xl object-cover" />
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
