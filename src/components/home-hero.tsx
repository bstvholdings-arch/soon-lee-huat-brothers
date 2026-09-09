"use client";

import { useLocale } from "./locale-provider";
import { useLoan } from "./loan-modal";
import { telLink, whatsappLink } from "@/lib/i18n";

export function HomeHero({
  companyName,
  companyReg,
  tagline,
  subtitle,
  phone,
  whatsapp,
}: {
  companyName: string;
  companyReg?: string;
  tagline: string;
  subtitle: string;
  phone: string;
  whatsapp: string;
}) {
  const { t } = useLocale();
  const { openLoan } = useLoan();
  return (
    <section className="overflow-hidden rounded-3xl border border-zinc-200 bg-white p-6 sm:p-10">
      <p className="text-sm font-medium uppercase tracking-[0.2em] text-zinc-500">Kepala Batas · Penang</p>
      <h1 className="mt-3 max-w-3xl text-3xl font-bold tracking-tight text-zinc-900 sm:text-5xl">{companyName}</h1>
      {companyReg ? (
        <p className="mt-2 text-sm font-medium text-zinc-500">{companyReg}</p>
      ) : null}
      <p className="mt-4 max-w-2xl text-base text-zinc-700 sm:text-lg">{tagline}</p>
      <p className="mt-2 max-w-2xl text-sm text-zinc-500">{subtitle}</p>
      <div className="mt-6 flex flex-wrap gap-3">
        <button
          type="button"
          onClick={() => openLoan()}
          className="rounded-xl bg-zinc-900 px-5 py-3 text-sm font-semibold text-white hover:bg-zinc-700"
        >
          {t("loanCta")}
        </button>
        <a
          href={whatsappLink(whatsapp, "Hi, I would like to enquire about a motorcycle.")}
          target="_blank"
          rel="noreferrer"
          className="rounded-xl bg-zinc-900 px-5 py-3 text-sm font-semibold text-white hover:bg-zinc-700"
        >
          WhatsApp
        </a>
        {phone ? (
          <a href={telLink(phone)} className="rounded-xl border border-zinc-300 px-5 py-3 text-sm font-semibold text-zinc-800">
            {t("call")} {phone}
          </a>
        ) : null}
      </div>
    </section>
  );
}
