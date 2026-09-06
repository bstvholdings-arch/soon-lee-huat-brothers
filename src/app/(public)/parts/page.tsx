import { PartsView } from "@/components/parts-view";
import { contentText } from "@/lib/i18n";
import { getParts, getSiteContent } from "@/lib/queries";

export default async function PartsPage() {
  const [content, parts] = await Promise.all([getSiteContent(), getParts()]);
  const phone = contentText(content, "phone", "en");
  const whatsapp = contentText(content, "whatsapp", "en") || phone;
  return <PartsView parts={parts} whatsapp={whatsapp} />;
}
