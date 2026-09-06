import { AdminNav } from "@/components/admin/admin-nav";
import { MotorcycleEditor } from "@/components/admin/motorcycle-editor";
import { getMotorcycle } from "@/lib/queries";
import { notFound } from "next/navigation";

export const dynamic = "force-dynamic";

export default async function EditMotorcyclePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const bike = await getMotorcycle(id);
  if (!bike) notFound();
  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-4xl px-4 py-8">
        <h1 className="mb-6 text-2xl font-bold">Edit motorcycle</h1>
        <MotorcycleEditor initial={bike} />
      </div>
    </>
  );
}
