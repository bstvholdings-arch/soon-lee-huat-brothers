import { UsedBikesView } from "@/components/used-bikes-view";
import { getMotorcycles, getSiteContent } from "@/lib/queries";

export default async function UsedBikesPage() {
  const [content, bikes] = await Promise.all([getSiteContent(), getMotorcycles("used")]);
  return <UsedBikesView content={content} bikes={bikes} />;
}
