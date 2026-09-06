import { NextRequest, NextResponse } from "next/server";
import { authenticateV1, touchV1 } from "@/lib/api-v1-auth";
import { getMotorcycles, getParts } from "@/lib/queries";

export async function GET(req: NextRequest) {
  const auth = await authenticateV1(req);
  if (!auth.ok) {
    return NextResponse.json(
      { error: "Unauthorized", detail: "Missing or invalid Authorization: Bearer <API_SECRET>" },
      { status: 401 },
    );
  }
  if (auth.key) void touchV1(auth.key);

  const [bikes, parts] = await Promise.all([getMotorcycles(), getParts()]);

  const products = [
    ...(bikes ?? []).map((b) => ({
      product_type: "motorcycle",
      sku: (b as Record<string, unknown>).sku ?? "",
      id: b.id,
      title: b.title_en,
      price: b.price,
      stock_quantity: (b as Record<string, unknown>).stock_quantity ?? 0,
      status: b.status,
    })),
    ...(parts ?? []).map((p) => ({
      product_type: "part",
      sku: (p as Record<string, unknown>).sku ?? "",
      id: p.id,
      title: p.name_en,
      price: p.price,
      stock_quantity: (p as Record<string, unknown>).stock_quantity ?? 0,
      stock_status: p.stock_status,
    })),
  ];

  return NextResponse.json({ products });
}
