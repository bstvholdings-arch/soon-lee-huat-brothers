"use client";

import { FormEvent, useEffect, useState } from "react";
import { AdminNav } from "@/components/admin/admin-nav";
import { createBrowserSupabase, isSupabaseConfigured } from "@/lib/supabase/client";

type OrderItem = {
  product_type: string;
  sku: string;
  name: string;
  quantity: number;
  unit_price: number;
};

type Order = {
  id: string;
  order_number: string;
  buyer_name: string;
  buyer_email: string | null;
  buyer_phone: string | null;
  shipping_address: Record<string, unknown>;
  status: string;
  external_ref: string | null;
  notes: string | null;
  created_at: string;
  items: OrderItem[];
};

const STATUS_LABEL: Record<string, string> = {
  pending_shipment: "待发货 / Pending shipment",
  shipped: "已发货 / Shipped",
  delivered: "已送达 / Delivered",
  cancelled: "已取消 / Cancelled",
};

export default function AdminOrdersPage() {
  const configured = isSupabaseConfigured();
  const [orders, setOrders] = useState<Order[]>([]);
  const [error, setError] = useState("");
  const [busyId, setBusyId] = useState<string | null>(null);

  async function load() {
    if (!configured) return;
    const supabase = createBrowserSupabase();
    const { data, error: qErr } = await supabase
      .from("orders")
      .select("*, items:order_items(*)")
      .order("created_at", { ascending: false });
    if (qErr) setError(qErr.message);
    else setOrders((data ?? []) as Order[]);
  }

  useEffect(() => {
    void load();
  }, [configured]);

  async function setStatus(id: string, status: string) {
    setError("");
    setBusyId(id);
    try {
      const supabase = createBrowserSupabase();
      const { error: uErr } = await supabase.from("orders").update({ status }).eq("id", id);
      if (uErr) throw uErr;
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update status");
    } finally {
      setBusyId(null);
    }
  }

  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-5xl space-y-6 px-4 py-8">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold">Orders</h1>
          <button
            type="button"
            onClick={() => load()}
            className="rounded-lg border border-white/15 px-3 py-1.5 text-sm hover:bg-white/10"
          >
            Refresh
          </button>
        </div>

        {!configured ? (
          <p className="text-sm text-amber-400">
            Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to .env.local, then restart the
            dev server.
          </p>
        ) : null}
        {error ? (
          <p className="rounded-lg bg-red-500/10 px-3 py-2 text-sm text-red-300">{error}</p>
        ) : null}

        {orders.length === 0 ? (
          <p className="rounded-2xl border border-white/10 bg-zinc-900 p-6 text-zinc-400">
            No orders yet. Orders pushed to <code className="rounded bg-zinc-800 px-1">/api/v1/orders</code> will
            appear here as “待发货 / Pending shipment”.
          </p>
        ) : (
          <div className="space-y-4">
            {orders.map((o) => (
              <div key={o.id} className="rounded-2xl border border-white/10 bg-zinc-900 p-5">
                <div className="flex flex-wrap items-start justify-between gap-2">
                  <div>
                    <p className="font-semibold text-white">{o.order_number}</p>
                    <p className="text-sm text-zinc-400">
                      {o.buyer_name}
                      {o.buyer_phone ? ` · ${o.buyer_phone}` : ""}
                      {o.buyer_email ? ` · ${o.buyer_email}` : ""}
                    </p>
                    <p className="mt-1 text-xs text-zinc-500">
                      {new Date(o.created_at).toLocaleString()}
                      {o.external_ref ? ` · ref: ${o.external_ref}` : ""}
                    </p>
                  </div>
                  <span className="rounded-full bg-red-500/15 px-3 py-1 text-xs font-medium text-red-300">
                    {STATUS_LABEL[o.status] ?? o.status}
                  </span>
                </div>

                <ul className="mt-3 space-y-1 text-sm text-zinc-300">
                  {o.items?.map((it, i) => (
                    <li key={i} className="flex justify-between">
                      <span>
                        {it.name || it.sku} {it.sku ? `(${it.sku})` : ""} × {it.quantity}
                      </span>
                      <span>RM {Number(it.unit_price).toFixed(2)}</span>
                    </li>
                  ))}
                </ul>

                {o.shipping_address && Object.keys(o.shipping_address).length > 0 ? (
                  <p className="mt-2 text-xs text-zinc-500">
                    Ship to: {JSON.stringify(o.shipping_address)}
                  </p>
                ) : null}

                <div className="mt-4 flex flex-wrap gap-2">
                  <button
                    type="button"
                    disabled={busyId === o.id || o.status === "shipped"}
                    onClick={() => setStatus(o.id, "shipped")}
                    className="rounded-lg bg-emerald-600 px-3 py-1.5 text-sm font-semibold text-white disabled:opacity-50"
                  >
                    Mark shipped
                  </button>
                  <button
                    type="button"
                    disabled={busyId === o.id || o.status === "delivered"}
                    onClick={() => setStatus(o.id, "delivered")}
                    className="rounded-lg border border-white/15 px-3 py-1.5 text-sm disabled:opacity-50"
                  >
                    Mark delivered
                  </button>
                  <button
                    type="button"
                    disabled={busyId === o.id || o.status === "cancelled"}
                    onClick={() => setStatus(o.id, "cancelled")}
                    className="rounded-lg border border-red-500/40 px-3 py-1.5 text-sm text-red-300 disabled:opacity-50"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}
