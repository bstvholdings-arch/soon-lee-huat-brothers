import { AboutView } from "@/components/about-view";
import { getSiteContent } from "@/lib/queries";

export default async function AboutPage() {
  const content = await getSiteContent();
  return <AboutView content={content} />;
}
