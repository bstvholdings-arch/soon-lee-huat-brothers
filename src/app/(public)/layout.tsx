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
  const facebookUrl = contentText(content, "facebook_url", "en");
  const tiktokUrl = contentText(content, "tiktok_url", "en");
  const instagramUrl = contentText(content, "instagram_url", "en");
  const logoImages = content["logo"]?.images;
  const logo = logoImages && logoImages.length ? logoImages[0] : undefined;

  return (
    <SiteShell
      companyName={company}
      phone={phone}
      whatsapp={whatsapp}
      address={address}
      logo={logo}
      facebookUrl={facebookUrl}
      tiktokUrl={tiktokUrl}
      instagramUrl={instagramUrl}
    >
      {children}
    </SiteShell>
  );
}
