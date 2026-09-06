"use client";

import { FormEvent, useEffect, useState } from "react";
import { AdminNav } from "@/components/admin/admin-nav";
import { createBrowserSupabase, isSupabaseConfigured } from "@/lib/supabase/client";

type ApiKeyRow = {
  id: string;
  name: string;
  key: string;
  revoked: boolean;
  created_at: string;
  last_used_at: string | null;
};

function generateKey(): string {
  const bytes = new Uint8Array(24);
  crypto.getRandomValues(bytes);
  const b64 = btoa(String.fromCharCode(...bytes)).replace(/[+/=]/g, "");
  return `slh_${b64}`;
}

export default function AdminApiKeysPage() {
  const configured = isSupabaseConfigured();
  const [rows, setRows] = useState<ApiKeyRow[]>([]);
  const [name, setName] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const [newKey, setNewKey] = useState<string | null>(null);

  async function load() {
    if (!configured) return;
    const supabase = createBrowserSupabase();
    const { data, error: qErr } = await supabase
      .from("api_keys")
      .select("*")
      .order("created_at", { ascending: false });
    if (qErr) setError(qErr.message);
    else setRows((data ?? []) as ApiKeyRow[]);
  }

  useEffect(() => {
    void load();
  }, [configured]);

  async function onCreate(e: FormEvent) {
    e.preventDefault();
    setError("");
    setBusy(true);
    try {
      const key = generateKey();
      const supabase = createBrowserSupabase();
      const { error: insErr } = await supabase
        .from("api_keys")
        .insert({ name: name.trim() || "Untitled key", key });
      if (insErr) throw insErr;
      setNewKey(key); // reveal only once
      setName("");
      await load();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to create key");
    } finally {
      setBusy(false);
    }
  }

  async function onRevoke(id: string) {
    setError("");
    const supabase = createBrowserSupabase();
    const { error: delErr } = await supabase.from("api_keys").delete().eq("id", id);
    if (delErr) setError(delErr.message);
    else await load();
  }

  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-3xl space-y-6 px-4 py-8">
        <h1 className="text-2xl font-bold">API keys</h1>
        <p className="text-sm text-zinc-400">
          Generate keys so external apps can read site data via the API. Pass a key as the{" "}
          <code className="rounded bg-zinc-800 px-1">x-api-key</code> header (or{" "}
          <code className="rounded bg-zinc-800 px-1">Bearer</code> token).
        </p>

        {!configured ? (
          <p className="text-sm text-amber-400">
            Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to .env.local, then restart the
            dev server.
          </p>
        ) : null}

        {error ? (
          <p className="rounded-lg bg-red-500/10 px-3 py-2 text-sm text-red-300">{error}</p>
        ) : null}

        {newKey ? (
          <div className="rounded-2xl border border-emerald-500/40 bg-emerald-500/10 p-4">
            <p className="text-sm font-semibold text-emerald-300">Key created (shown once — copy it now)</p>
            <code className="mt-2 block break-all rounded-lg bg-zinc-950 px-3 py-2 text-sm text-white">
              {newKey}
            </code>
            <button
              type="button"
              onClick={() => setNewKey(null)}
              className="mt-2 text-xs text-zinc-400 hover:text-white"
            >
              Dismiss
            </button>
          </div>
        ) : null}

        <form onSubmit={onCreate} className="flex flex-wrap items-end gap-3 rounded-2xl border border-white/10 bg-zinc-900 p-5">
          <label className="block flex-1 text-sm">
            Key name (optional)
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Mobile app"
              className="mt-1 w-full rounded-lg border border-white/10 bg-zinc-950 px-3 py-2"
            />
          </label>
          <button
            type="submit"
            disabled={busy || !configured}
            className="rounded-xl bg-red-600 px-5 py-2 font-semibold disabled:opacity-50"
          >
            Generate key
          </button>
        </form>

        <div className="overflow-hidden rounded-2xl border border-white/10">
          <table className="w-full text-sm">
            <thead className="bg-zinc-900 text-zinc-400">
              <tr>
                <th className="px-3 py-2 text-left">Name</th>
                <th className="px-3 py-2 text-left">Key</th>
                <th className="px-3 py-2 text-left">Last used</th>
                <th className="px-3 py-2 text-right">Action</th>
              </tr>
            </thead>
            <tbody>
              {rows.length === 0 ? (
                <tr>
                  <td colSpan={4} className="px-3 py-4 text-center text-zinc-500">
                    No API keys yet.
                  </td>
                </tr>
              ) : (
                rows.map((row) => (
                  <tr key={row.id} className="border-t border-white/10">
                    <td className="px-3 py-2">{row.name}</td>
                    <td className="px-3 py-2 font-mono text-xs text-zinc-300">
                      {row.revoked ? "revoked" : `${row.key.slice(0, 12)}…`}
                    </td>
                    <td className="px-3 py-2 text-zinc-400">
                      {row.last_used_at ? new Date(row.last_used_at).toLocaleString() : "—"}
                    </td>
                    <td className="px-3 py-2 text-right">
                      {row.revoked ? (
                        <span className="text-zinc-600">revoked</span>
                      ) : (
                        <button
                          type="button"
                          onClick={() => onRevoke(row.id)}
                          className="text-red-400 hover:underline"
                        >
                          Revoke
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>

        <div className="rounded-2xl border border-white/10 bg-zinc-900 p-5 text-sm text-zinc-300">
          <p className="font-semibold text-white">Example requests</p>
          <pre className="mt-2 overflow-x-auto rounded-lg bg-zinc-950 p-3 text-xs">{`curl https://your-domain/api/site -H "x-api-key: YOUR_KEY"
curl https://your-domain/api/motorcycles?type=new -H "x-api-key: YOUR_KEY"
curl https://your-domain/api/parts -H "x-api-key: YOUR_KEY"`}</pre>
        </div>
      </div>
    </>
  );
}
