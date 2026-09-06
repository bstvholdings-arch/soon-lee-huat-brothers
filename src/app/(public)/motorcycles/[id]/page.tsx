import { MotorcycleDetail } from "@/components/motorcycle-detail";
import { contentText } from "@/lib/i18n";
import { getMotorcycle, getSiteContent } from "@/lib/queries";
import { notFound } from "next/navigation";

export default async function MotorcyclePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const [bike, content] = await Promise.all([getMotorcycle(id), getSiteContent()]);
  if (!bike) notFound();
  const phone = contentText(content, "phone", "en");
  const whatsapp = contentText(content, "whatsapp", "en") || phone;
  return <MotorcycleDetail bike={bike} whatsapp={whatsapp} />;
}
