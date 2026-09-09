import { AdminNav } from "@/components/admin/admin-nav";
import { MotorcycleEditor } from "@/components/admin/motorcycle-editor";
import { LocaleProvider } from "@/components/locale-provider";

export default function NewMotorcyclePage() {
  return (
    <LocaleProvider>
      <AdminNav />
      <div className="mx-auto max-w-4xl px-4 py-8">
        <h1 className="mb-6 text-2xl font-bold">Add motorcycle</h1>
        <MotorcycleEditor />
      </div>
    </LocaleProvider>
  );
}
