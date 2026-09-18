import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

const ADMIN_ROLE = "admin";

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const isAdminRoute = pathname.startsWith("/admin");
  const isAdminLogin = pathname.startsWith("/admin/login");
  const isApiAdmin = pathname.startsWith("/api/admin");

  let response = NextResponse.next({ request });

  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  // No Supabase config: at least keep the page route behind the login screen.
  if (!url || !key) {
    if (isAdminRoute && !isAdminLogin) {
      return NextResponse.redirect(new URL("/admin/login", request.url));
    }
    return response;
  }

  const supabase = createServerClient(url, key, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) =>
          response.cookies.set(name, value, options),
        );
      },
    },
  });

  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Login page: if already signed in, bounce to the dashboard.
  if (isAdminLogin) {
    if (user) return NextResponse.redirect(new URL("/admin", request.url));
    return response;
  }

  // Everything under /admin (pages) or /api/admin requires an authenticated user.
  if ((isAdminRoute || isApiAdmin) && !user) {
    if (isApiAdmin) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }
    return NextResponse.redirect(new URL("/admin/login", request.url));
  }

  // Admin gate: app_metadata.role must equal "admin".
  const role = (user?.app_metadata as { role?: string } | undefined)?.role;
  const isAdmin = role === ADMIN_ROLE;

  if ((isAdminRoute || isApiAdmin) && !isAdmin) {
    if (isApiAdmin) {
      return NextResponse.json({ error: "Forbidden: admin role required" }, { status: 403 });
    }
    // Page request from a non-admin, authenticated user -> send home.
    return NextResponse.redirect(new URL("/", request.url));
  }

  return response;
}

export const config = {
  // Protect admin pages AND any future /api/admin/* route handlers.
  matcher: ["/admin/:path*", "/api/admin/:path*"],
};
