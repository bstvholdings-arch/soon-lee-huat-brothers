import { NextRequest, NextResponse } from "next/server";
import { authenticateV1, touchV1 } from "@/lib/api-v1-auth";
import { createAnonClient } from "@/lib/supabase/client";
import { notifyAdminViaWhatsApp } from "@/lib/notify";

export async function POST(req: NextRequest) {
  const auth = await authenticateV1(req);
  if (!auth.ok) {
    void notifyAdminViaWhatsApp(
      `⚠️ SLH order API: unauthorized POST attempt blocked (missing/invalid API key) at ${new Date().toISOString()}.`,
    );
    return NextResponse.json(
      { error: "Unauthorized", detail: "Missing or invalid Authorization: Bearer <API_SECRET>" },
      { status: 401 },
    );
  }
  if (auth.key) void touchV1(auth.key);

  let body: Record<string, unknown>;
  try {
    body = (await req.json()) as Record<string, unknown>;
  } catch {
    return NextResponse.json({ error: "Bad Request", detail: "Invalid JSON body" }, { status: 400 });
  }

  // basic field presence validation
  const buyerName = typeof body.buyer_name === "string" ? body.buyer_name : "";
  const items = body.items;
  if (!buyerName) {
    void notifyAdminViaWhatsApp("⚠️ SLH order API: rejected order — buyer_name missing.");
    return NextResponse.json({ error: "Bad Request", detail: "buyer_name is required" }, { status: 400 });
  }
  if (!Array.isArray(items) || items.length === 0) {
    void notifyAdminViaWhatsApp("⚠️ SLH order API: rejected order — items empty/missing.");
    return NextResponse.json({ error: "Bad Request", detail: "items must be a non-empty array" }, { status: 400 });
  }

  const supabase = createAnonClient();
  if (!supabase) {
    return NextResponse.json({ error: "Service Unavailable", detail: "Database not configured" }, { status: 503 });
  }

  const { data, error } = await supabase.rpc("create_order", {
    p_buyer_name: buyerName,
    p_buyer_email: typeof body.buyer_email === "string" ? body.buyer_email : null,
    p_buyer_phone: typeof body.buyer_phone === "string" ? body.buyer_phone : null,
    p_shipping_address: (body.shipping_address ?? {}) as Record<string, unknown> as never,
    p_notes: typeof body.notes === "string" ? body.notes : null,
    p_external_ref: typeof body.external_ref === "string" ? body.external_ref : null,
    p_items: items as never,
  });

  if (error) {
    const msg = error.message || "";
    if (msg.startsWith("insufficient_stock")) {
      const sku = msg.split(":")[1];
      void notifyAdminViaWhatsApp(`🚨 SLH order FAILED — insufficient stock for SKU ${sku}. Order may be lost; check supplier.`);
      return NextResponse.json(
        { error: "Conflict", detail: `Insufficient stock for SKU ${sku}` },
        { status: 409 },
      );
    }
    if (msg.startsWith("unknown_sku")) {
      const sku = msg.split(":")[1];
      void notifyAdminViaWhatsApp(`🚨 SLH order FAILED — unknown SKU ${sku}. Verify product sync.`);
      return NextResponse.json(
        { error: "Bad Request", detail: `Unknown SKU ${sku}` },
        { status: 400 },
      );
    }
    if (msg === "missing_items") {
      void notifyAdminViaWhatsApp("🚨 SLH order FAILED — items array empty in DB function.");
      return NextResponse.json({ error: "Bad Request", detail: "items array is empty" }, { status: 400 });
    }
    void notifyAdminViaWhatsApp(`🚨 SLH order FAILED — internal error: ${msg}`);
    return NextResponse.json({ error: "Internal Error", detail: msg }, { status: 500 });
  }

  const result = data as { order_id: string; order_number: string; status: string };
  return NextResponse.json(
    {
      ok: true,
      order_id: result.order_id,
      order_number: result.order_number,
      status: result.status,
      message: "Order received. Status initialized as pending_shipment.",
    },
    { status: 200 },
  );
}
