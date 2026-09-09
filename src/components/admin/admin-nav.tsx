"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { createBrowserSupabase } from "@/lib/supabase/client";

const links = [
  { href: "/admin", label: "Dashboard" },
  { href: "/admin/motorcycles", label: "Motorcycles" },
  { href: "/admin/parts", label: "Parts" },
  { href: "/admin/brands", label: "Brands" },
  { href: "/admin/content", label: "Content & gallery" },
  { href: "/admin/account", label: "Account" },
  { href: "/admin/api-keys", label: "API keys" },
  { href: "/admin/orders", label: "Orders" },
];

export function AdminNav() {
  const pathname = usePathname();
  const router = useRouter();

  async function logout() {
    const supabase = createBrowserSupabase();
    await supabase.auth.signOut();
    router.replace("/admin/login");
    router.refresh();
  }

  return (
    <header className="border-b border-zinc-200 bg-white">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-4 py-3">
        <p className="text-sm font-semibold">SLH Admin CMS</p>
        <nav className="flex flex-wrap gap-3 text-sm">
          {links.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={pathname === link.href ? "text-zinc-900" : "text-zinc-500 hover:text-zinc-900"}
            >
              {link.label}
            </Link>
          ))}
          <Link href="/" className="text-zinc-500 hover:text-zinc-900">
            View site
          </Link>
          <button type="button" onClick={logout} className="text-zinc-500 hover:text-zinc-900">
            Sign out
          </button>
        </nav>
      </div>
    </header>
  );
}
