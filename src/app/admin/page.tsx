import Link from "next/link";
import { AdminNav } from "@/components/admin/admin-nav";

export default function AdminHomePage() {
  const cards = [
    { href: "/admin/motorcycles", title: "Motorcycles", body: "New and used bikes, colours, angles, pricing, stock." },
    { href: "/admin/parts", title: "Parts", body: "Helmets, oils, top boxes, spare parts." },
    { href: "/admin/brands", title: "Brands", body: "Partner logos and display order." },
    { href: "/admin/content", title: "Content & gallery", body: "About text, contact, hours, store photos." },
    { href: "/admin/account", title: "Account", body: "Change your login password and email." },
    { href: "/admin/api-keys", title: "API keys", body: "Generate keys so external apps can read site data." },
    { href: "/admin/orders", title: "Orders", body: "External orders pushed via the API, ready to ship." },
  ];
  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-6xl px-4 py-8">
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="mt-2 text-zinc-400">Manage all public website content from these modules.</p>
        <div className="mt-6 grid gap-4 md:grid-cols-2">
          {cards.map((card) => (
            <Link key={card.href} href={card.href} className="rounded-2xl border border-white/10 bg-zinc-900 p-5 hover:border-red-500">
              <h2 className="text-lg font-semibold">{card.title}</h2>
              <p className="mt-2 text-sm text-zinc-400">{card.body}</p>
            </Link>
          ))}
        </div>
      </div>
    </>
  );
}
