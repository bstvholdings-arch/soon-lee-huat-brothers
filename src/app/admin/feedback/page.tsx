"use client";

import { useEffect, useState } from "react";
import { AdminNav } from "@/components/admin/admin-nav";
import { createBrowserSupabase, isSupabaseConfigured } from "@/lib/supabase/client";
import type { Feedback } from "@/lib/types";

const STATUS_LABEL: Record<string, string> = {
  pending: "待审核 / Pending",
  approved: "已发布 / Approved",
  rejected: "已拒绝 / Rejected",
};

export default function AdminFeedbackPage() {
  const configured = isSupabaseConfigured();
  const [items, setItems] = useState<Feedback[]>([]);
  const [error, setError] = useState("");
  const [busyId, setBusyId] = useState<string | null>(null);

  async function load() {
    if (!configured) return;
    const supabase = createBrowserSupabase();
    const { data, error: qErr } = await supabase
      .from("feedback")
      .select("id, name, rating, message, status, created_at")
      .order("created_at", { ascending: false });
    if (qErr) setError(qErr.message);
    else setItems((data ?? []) as Feedback[]);
  }

  useEffect(() => {
    void load();
  }, [configured]);

  async function act(id: string, status: string) {
    setError("");
    setBusyId(id);
    try {
      const supabase = createBrowserSupabase();
      const { error: uErr } = await supabase.from("feedback").update({ status }).eq("id", id);
      if (uErr) throw uErr;
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update");
    } finally {
      setBusyId(null);
    }
  }

  async function remove(id: string) {
    setError("");
    setBusyId(id);
    try {
      const supabase = createBrowserSupabase();
      const { error: dErr } = await supabase.from("feedback").delete().eq("id", id);
      if (dErr) throw dErr;
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to delete");
    } finally {
      setBusyId(null);
    }
  }

  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-5xl space-y-6 px-4 py-8">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold">Customer feedback</h1>
          <button
            type="button"
            onClick={() => load()}
            className="rounded-lg border border-zinc-200 px-3 py-1.5 text-sm hover:bg-zinc-50"
          >
            Refresh
          </button>
        </div>

        {!configured ? (
          <p className="text-sm text-amber-600">
            Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to .env.local, then restart the
            dev server.
          </p>
        ) : null}
        {error ? (
          <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600">{error}</p>
        ) : null}

        {items.length === 0 ? (
          <p className="rounded-2xl border border-zinc-200 bg-white p-6 text-zinc-500">
            No feedback yet. Visitor submissions appear here as “待审核 / Pending”.
          </p>
        ) : (
          <div className="space-y-4">
            {items.map((f) => (
              <div key={f.id} className="rounded-2xl border border-zinc-200 bg-white p-5">
                <div className="flex flex-wrap items-start justify-between gap-2">
                  <div>
                    <p className="font-semibold text-zinc-900">{f.name}</p>
                    <p className="text-xs text-zinc-500">{new Date(f.created_at).toLocaleString()}</p>
                    {f.rating ? (
                      <p className="mt-1 text-red-600" aria-label={`${f.rating} stars`}>
                        {"★".repeat(f.rating)}
                        <span className="text-zinc-300">{"★".repeat(5 - f.rating)}</span>
                      </p>
                    ) : null}
                  </div>
                  <span className="rounded-full bg-zinc-100 px-3 py-1 text-xs font-medium text-zinc-700">
                    {STATUS_LABEL[f.status] ?? f.status}
                  </span>
                </div>
                <p className="mt-2 whitespace-pre-wrap text-sm text-zinc-700">{f.message}</p>

                <div className="mt-4 flex flex-wrap gap-2">
                  <button
                    type="button"
                    disabled={busyId === f.id || f.status === "approved"}
                    onClick={() => act(f.id, "approved")}
                    className="rounded-lg bg-zinc-900 px-3 py-1.5 text-sm font-semibold text-white disabled:opacity-50"
                  >
                    Approve & publish
                  </button>
                  <button
                    type="button"
                    disabled={busyId === f.id || f.status === "rejected"}
                    onClick={() => act(f.id, "rejected")}
                    className="rounded-lg border border-zinc-200 px-3 py-1.5 text-sm disabled:opacity-50"
                  >
                    Reject
                  </button>
                  <button
                    type="button"
                    disabled={busyId === f.id}
                    onClick={() => remove(f.id)}
                    className="rounded-lg border border-red-500/40 px-3 py-1.5 text-sm text-red-600 disabled:opacity-50"
                  >
                    Delete
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
