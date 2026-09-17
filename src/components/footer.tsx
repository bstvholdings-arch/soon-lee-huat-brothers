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
    { label: "Facebook", href: facebookUrl, icon: "facebook" },
    { label: "TikTok", href: tiktokUrl, icon: "tiktok" },
    { label: "Instagram", href: instagramUrl, icon: "instagram" },
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
              aria-label={s.label}
              title={s.label}
              className="flex h-9 w-9 items-center justify-center rounded-lg bg-red-600 text-white hover:bg-red-500"
            >
              <SocialIcon name={s.icon} />
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

function SocialIcon({ name }: { name: string }) {
  const common = { width: 18, height: 18, viewBox: "0 0 24 24", fill: "currentColor" } as const;
  if (name === "facebook")
    return (
      <svg {...common} aria-hidden="true">
        <path d="M22 12.06C22 6.5 17.52 2 12 2S2 6.5 2 12.06c0 5 3.66 9.15 8.44 9.94v-7.03H7.9v-2.9h2.54V9.85c0-2.51 1.49-3.9 3.78-3.9 1.1 0 2.24.2 2.24.2v2.46h-1.26c-1.24 0-1.63.78-1.63 1.57v1.89h2.78l-.45 2.9h-2.33V22c4.78-.79 8.43-4.94 8.43-9.94Z" />
      </svg>
    );
  if (name === "tiktok")
    return (
      <svg {...common} aria-hidden="true">
        <path d="M16.5 3c.4 2.3 1.7 3.9 4 4.2v3c-1.5 0-2.9-.4-4-1.1v6.4c0 3.2-2.4 5.5-5.6 5.5-3 0-5.4-2.2-5.4-5.1 0-3 2.4-5.1 5.4-5.1.3 0 .6 0 .9.1v3.1c-.3-.1-.6-.2-.9-.2-1.2 0-2.1.9-2.1 2.2 0 1.3.9 2.2 2.1 2.2 1.3 0 2.2-1 2.2-2.6V3h3.4Z" />
      </svg>
    );
  return (
    <svg {...common} aria-hidden="true">
      <path d="M12 2.2c3.2 0 3.6 0 4.85.07 1.17.05 1.8.25 2.23.41.56.22.96.48 1.38.9.42.42.68.82.9 1.38.16.42.36 1.06.41 2.23.06 1.25.07 1.65.07 4.85s0 3.6-.07 4.85c-.05 1.17-.25 1.8-.41 2.23-.22.56-.48.96-.9 1.38-.42.42-.82.68-1.38.9-.42.16-1.06.36-2.23.41-1.25.06-1.65.07-4.85.07s-3.6 0-4.85-.07c-1.17-.05-1.8-.25-2.23-.41a3.7 3.7 0 0 1-1.38-.9 3.7 3.7 0 0 1-.9-1.38c-.16-.42-.36-1.06-.41-2.23C2.2 15.6 2.2 15.2 2.2 12s0-3.6.07-4.85c.05-1.17.25-1.8.41-2.23.22-.56.48-.96.9-1.38.42-.42.82-.68 1.38-.9.42-.16 1.06-.36 2.23-.41C8.4 2.2 8.8 2.2 12 2.2Zm0 1.8c-3.14 0-3.51.01-4.75.07-.9.04-1.38.19-1.7.32-.43.16-.74.36-1.06.68-.32.32-.52.63-.68 1.06-.13.32-.28.8-.32 1.7C3.41 8.49 3.4 8.86 3.4 12s.01 3.51.07 4.75c.04.9.19 1.38.32 1.7.16.43.36.74.68 1.06.32.32.63.52 1.06.68.32.13.8.28 1.7.32 1.24.06 1.61.07 4.75.07s3.51-.01 4.75-.07c.9-.04 1.38-.19 1.7-.32.43-.16.74-.36 1.06-.68.32-.32.52-.63.68-1.06.13-.32.28-.8.32-1.7.06-1.24.07-1.61.07-4.75s-.01-3.51-.07-4.75c-.04-.9-.19-1.38-.32-1.7a2.85 2.85 0 0 0-.68-1.06 2.85 2.85 0 0 0-1.06-.68c-.32-.13-.8-.28-1.7-.32C15.51 4.01 15.14 4 12 4Zm0 3.06A4.94 4.94 0 1 1 7.06 12 4.94 4.94 0 0 1 12 7.06Zm0 1.8A3.14 3.14 0 1 0 15.14 12 3.14 3.14 0 0 0 12 8.86Zm5.13-3.2a1.15 1.15 0 1 1-1.15 1.15 1.15 1.15 0 0 1 1.15-1.15Z" />
    </svg>
  );
}
