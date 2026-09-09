import type { Metadata } from "next";
import { Geist, Noto_Sans_SC } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const notoSc = Noto_Sans_SC({
  variable: "--font-noto-sc",
  subsets: ["latin"],
  weight: ["400", "500", "700"],
});

export const metadata: Metadata = {
  title: "Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.",
  description:
    "New and used motorcycles, parts and accessories in Kepala Batas, Penang.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className={`${geistSans.variable} ${notoSc.variable} h-full antialiased`}>
      <body className="flex min-h-full flex-col bg-white text-zinc-900">{children}</body>
    </html>
  );
}
