import { UsedBikesView } from "@/components/used-bikes-view";
import { contentText } from "@/lib/i18n";
import { getMotorcycles, getSiteContent } from "@/lib/queries";

export default async function UsedBikesPage() {
  const [content, bikes] = await Promise.all([getSiteContent(), getMotorcycles("used")]);
  const phone = contentText(content, "phone", "en");
  const whatsapp = contentText(content, "whatsapp", "en") || phone;
  return <UsedBikesView bikes={bikes} whatsapp={whatsapp} />;
}
