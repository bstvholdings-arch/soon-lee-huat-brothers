import { HomeView } from "@/components/home-view";
import { contentText } from "@/lib/i18n";
import { getBrands, getMotorcycles, getSiteContent } from "@/lib/queries";

export default async function HomePage() {
  const [content, bikes, brands] = await Promise.all([
    getSiteContent(),
    getMotorcycles("new"),
    getBrands(),
  ]);
  const phone = contentText(content, "phone", "en");
  const whatsapp = contentText(content, "whatsapp", "en") || phone;
  return <HomeView content={content} bikes={bikes} brands={brands} whatsapp={whatsapp} />;
}
