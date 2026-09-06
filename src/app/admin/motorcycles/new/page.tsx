import { AdminNav } from "@/components/admin/admin-nav";
import { MotorcycleEditor } from "@/components/admin/motorcycle-editor";

export default function NewMotorcyclePage() {
  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-4xl px-4 py-8">
        <h1 className="mb-6 text-2xl font-bold">Add motorcycle</h1>
        <MotorcycleEditor />
      </div>
    </>
  );
}
