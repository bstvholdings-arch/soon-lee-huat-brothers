"use client";

import Link from "next/link";
import { useLocale } from "./locale-provider";

export function Footer({
  companyName,
  address,
  facebookUrl,
  tiktokUrl,
  instagramUrl,
}: {
  companyName: string;
  address: string;
  facebookUrl?: string;
  tiktokUrl?: string;
  instagramUrl?: string;
}) {
  const { t } = useLocale();
  const socials = [
    { label: "Facebook", href: facebookUrl },
    { label: "TikTok", href: tiktokUrl },
    { label: "Instagram", href: instagramUrl },
  ].filter((s) => s.href);
  return (
    <footer className="mt-auto border-t border-zinc-200 bg-white px-4 py-8 text-sm text-zinc-500">
      <div className="mx-auto flex max-w-6xl flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <p>
          {companyName}
          <span className="mx-2">·</span>
          {t("footerNote")}
          {address ? (
            <>
              <span className="mx-2">·</span>
              {address}
            </>
          ) : null}
        </p>
        <div className="flex flex-wrap items-center gap-2">
          {socials.map((s) => (
            <a
              key={s.label}
              href={s.href}
              target="_blank"
              rel="noreferrer"
              className="rounded-lg bg-red-600 px-3 py-2 text-xs font-semibold text-white hover:bg-red-500"
            >
              {s.label}
            </a>
          ))}
          <Link href="/admin" className="hover:text-zinc-900">
            {t("admin")}
          </Link>
        </div>
      </div>
    </footer>
  );
}
