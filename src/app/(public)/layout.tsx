import { SiteShell } from "@/components/site-shell";
import { contentText } from "@/lib/i18n";
import { getSiteContent } from "@/lib/queries";

export const dynamic = "force-dynamic";

export default async function PublicLayout({ children }: { children: React.ReactNode }) {
  const content = await getSiteContent();
  const company = contentText(
    content,
    "company_name",
    "en",
    "Soon Lee Huat Brothers Motor (KB) Sdn. Bhd.",
  );
  const phone = contentText(content, "phone", "en");
  const whatsapp = contentText(content, "whatsapp", "en") || phone;
  const address = contentText(content, "address", "en");

  return (
    <SiteShell companyName={company} phone={phone} whatsapp={whatsapp} address={address}>
      {children}
    </SiteShell>
  );
}
