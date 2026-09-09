"use client";

import Link from "next/link";
import { useState } from "react";
import type { Locale } from "@/lib/types";
import { telLink, whatsappLink } from "@/lib/i18n";
import { useLocale } from "./locale-provider";
import { useLoan } from "./loan-modal";

export function Header({
  companyName,
  phone,
  whatsapp,
  logo,
}: {
  companyName: string;
  phone: string;
  whatsapp: string;
  logo?: string;
}) {
  const { locale, setLocale, t } = useLocale();
  const { openLoan } = useLoan();
  const [open, setOpen] = useState(false);
  const wa = whatsappLink(whatsapp, "Hi, I would like to enquire about a motorcycle.");

  const nav = [
    { href: "/", label: t("navHome") },
    { href: "/used-bikes", label: t("navUsed") },
    { href: "/parts", label: t("navParts") },
    { href: "/about", label: t("navAbout") },
  ];

  return (
    <header className="sticky top-0 z-30 border-b border-zinc-200 bg-white/95 text-zinc-900 backdrop-blur">
      <div className="mx-auto flex max-w-6xl items-center justify-between gap-3 px-4 py-3">
        <Link href="/" className="flex min-w-0 items-center gap-3">
          {logo ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={logo} alt={companyName} className="h-10 w-10 rounded-lg object-contain" />
          ) : null}
          <div className="min-w-0">
            <p className="truncate text-sm font-bold tracking-tight sm:text-base">{companyName}</p>
            <p className="hidden text-xs text-zinc-500 sm:block">Kepala Batas · Penang</p>
          </div>
        </Link>
        <nav className="hidden items-center gap-5 text-sm md:flex">
          {nav.map((item) => (
            <Link key={item.href} href={item.href} className="text-zinc-600 hover:text-zinc-900">
              {item.label}
            </Link>
          ))}
        </nav>
        <div className="flex items-center gap-2">
          <LanguageSwitcher locale={locale} setLocale={setLocale} />
          {phone ? (
            <a href={telLink(phone)} className="hidden rounded-lg bg-zinc-100 px-3 py-2 text-xs font-medium sm:inline">
              {phone}
            </a>
          ) : null}
          <a
            href={wa}
            target="_blank"
            rel="noreferrer"
            className="rounded-lg bg-zinc-900 px-3 py-2 text-xs font-semibold text-white hover:bg-zinc-700"
          >
            WhatsApp
          </a>
          <button
            type="button"
            className="rounded-lg border border-zinc-300 px-2 py-2 text-xs text-zinc-700 md:hidden"
            onClick={() => setOpen((v) => !v)}
          >
            {t("menu")}
          </button>
        </div>
      </div>
      {open ? (
        <div className="border-t border-zinc-200 bg-white px-4 py-3 md:hidden">
          <div className="flex flex-col gap-2 text-sm">
            {nav.map((item) => (
              <Link key={item.href} href={item.href} onClick={() => setOpen(false)} className="text-zinc-700">
                {item.label}
              </Link>
            ))}
            <button type="button" className="text-left text-zinc-700" onClick={() => openLoan()}>
              {t("loanCta")}
            </button>
          </div>
        </div>
      ) : null}
    </header>
  );
}

function LanguageSwitcher({
  locale,
  setLocale,
}: {
  locale: Locale;
  setLocale: (l: Locale) => void;
}) {
  const options: { id: Locale; label: string }[] = [
    { id: "en", label: "EN" },
    { id: "bm", label: "BM" },
    { id: "zh", label: "中文" },
  ];
  return (
    <div className="flex overflow-hidden rounded-lg border border-white/15 text-xs font-semibold">
      {options.map((opt) => (
        <button
          key={opt.id}
          type="button"
          onClick={() => setLocale(opt.id)}
          className={`px-2 py-1.5 ${locale === opt.id ? "bg-zinc-900 text-white" : "text-zinc-600 hover:bg-zinc-100"}`}
        >
          {opt.label}
        </button>
      ))}
    </div>
  );
}
