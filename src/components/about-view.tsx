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
        <h1 className="text-3xl font-bold text-white">{t("aboutTitle")}</h1>
        <p className="mt-2 text-sm text-red-400">{company}</p>
        <p className="mt-4 max-w-3xl whitespace-pre-wrap text-zinc-200">{about}</p>
      </section>
      <section className="rounded-2xl border border-white/10 bg-zinc-900 p-6">
        <h2 className="text-xl font-semibold text-white">{t("location")}</h2>
        <div className="mt-4 space-y-2 text-zinc-200">
          {address ? (
            <p>
              <a href={mapLink(address)} target="_blank" rel="noreferrer" className="text-red-400 hover:underline">
                {address}
              </a>
            </p>
          ) : null}
          {hours ? <p>{hours}</p> : null}
          {phone ? (
            <p>
              <a href={telLink(phone)} className="text-red-400 hover:underline">
                {phone}
              </a>
            </p>
          ) : null}
        </div>
        <div className="mt-4 flex flex-wrap gap-3">
          {maps ? (
            <a href={maps} target="_blank" rel="noreferrer" className="rounded-xl bg-white px-4 py-2 text-sm font-semibold text-zinc-950">
              {t("maps")}
            </a>
          ) : null}
          {waze ? (
            <a href={waze} target="_blank" rel="noreferrer" className="rounded-xl bg-cyan-500 px-4 py-2 text-sm font-semibold text-black">
              {t("waze")}
            </a>
          ) : null}
        </div>
      </section>
      <section>
        <h2 className="mb-4 text-xl font-semibold text-white">{t("gallery")}</h2>
        {gallery.length === 0 ? (
          <p className="text-zinc-400">{t("emptyGallery")}</p>
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
