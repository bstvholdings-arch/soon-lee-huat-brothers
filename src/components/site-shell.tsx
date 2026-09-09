"use client";

import { Header } from "./header";
import { Footer } from "./footer";
import { LocaleProvider } from "./locale-provider";
import { LoanProvider } from "./loan-modal";

export function SiteShell({
  companyName,
  phone,
  whatsapp,
  address,
  logo,
  children,
}: {
  companyName: string;
  phone: string;
  whatsapp: string;
  address: string;
  logo?: string;
  children: React.ReactNode;
}) {
  return (
    <LocaleProvider>
      <LoanProvider whatsapp={whatsapp}>
        <Header companyName={companyName} phone={phone} whatsapp={whatsapp} logo={logo} />
        <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-8">{children}</main>
        <Footer companyName={companyName} address={address} />
      </LoanProvider>
    </LocaleProvider>
  );
}
