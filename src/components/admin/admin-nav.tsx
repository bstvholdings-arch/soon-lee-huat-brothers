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
    <header className="border-b border-white/10 bg-zinc-950">
      <div className="mx-auto flex max-w-6xl flex-wrap items-center justify-between gap-3 px-4 py-3">
        <p className="text-sm font-semibold">SLH Admin CMS</p>
        <nav className="flex flex-wrap gap-3 text-sm">
          {links.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={pathname === link.href ? "text-red-400" : "text-zinc-300 hover:text-white"}
            >
              {link.label}
            </Link>
          ))}
          <Link href="/" className="text-zinc-400 hover:text-white">
            View site
          </Link>
          <button type="button" onClick={logout} className="text-zinc-400 hover:text-white">
            Sign out
          </button>
        </nav>
      </div>
    </header>
  );
}
