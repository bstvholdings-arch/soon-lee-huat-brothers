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
    <section className="overflow-hidden rounded-3xl bg-gradient-to-br from-zinc-900 via-zinc-950 to-red-950 p-6 sm:p-10">
      <p className="text-sm font-medium uppercase tracking-[0.2em] text-red-400">Kepala Batas · Penang</p>
      <h1 className="mt-3 max-w-3xl text-3xl font-bold tracking-tight text-white sm:text-5xl">{companyName}</h1>
      {companyReg ? (
        <p className="mt-2 text-sm font-medium text-zinc-400">{companyReg}</p>
      ) : null}
      <p className="mt-4 max-w-2xl text-base text-zinc-200 sm:text-lg">{tagline}</p>
      <p className="mt-2 max-w-2xl text-sm text-zinc-400">{subtitle}</p>
      <div className="mt-6 flex flex-wrap gap-3">
        <button
          type="button"
          onClick={() => openLoan()}
          className="rounded-xl bg-red-600 px-5 py-3 text-sm font-semibold text-white hover:bg-red-500"
        >
          {t("loanCta")}
        </button>
        <a
          href={whatsappLink(whatsapp, "Hi, I would like to enquire about a motorcycle.")}
          target="_blank"
          rel="noreferrer"
          className="rounded-xl bg-emerald-500 px-5 py-3 text-sm font-semibold text-black"
        >
          WhatsApp
        </a>
        {phone ? (
          <a href={telLink(phone)} className="rounded-xl border border-white/20 px-5 py-3 text-sm font-semibold text-white">
            {t("call")} {phone}
          </a>
        ) : null}
      </div>
    </section>
  );
}
