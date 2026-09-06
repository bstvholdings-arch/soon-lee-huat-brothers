"use client";

import Link from "next/link";
import { useLocale } from "./locale-provider";
import { mapLink } from "@/lib/i18n";

export function Footer({ companyName, address }: { companyName: string; address: string }) {
  const { t } = useLocale();
  return (
    <footer className="mt-auto border-t border-white/10 bg-zinc-950 px-4 py-8 text-sm text-zinc-400">
      <div className="mx-auto flex max-w-6xl flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <p>
          {companyName}
          <span className="mx-2">·</span>
          {t("footerNote")}
          {address ? (
            <>
              <span className="mx-2">·</span>
              <a href={mapLink(address)} target="_blank" rel="noreferrer" className="hover:text-white hover:underline">
                {address}
              </a>
            </>
          ) : null}
        </p>
        <Link href="/admin" className="hover:text-white">
          {t("admin")}
        </Link>
      </div>
    </footer>
  );
}
