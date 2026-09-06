"use client";

import { useEffect, FormEvent, useState } from "react";
import { createBrowserSupabase, isSupabaseConfigured } from "@/lib/supabase/client";
import { AdminNav } from "@/components/admin/admin-nav";

export default function AdminAccountPage() {
  const configured = isSupabaseConfigured();
  const [currentEmail, setCurrentEmail] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [newEmail, setNewEmail] = useState("");
  const [msg, setMsg] = useState("");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!configured) return;
    (async () => {
      try {
        const supabase = createBrowserSupabase();
        const { data } = await supabase.auth.getUser();
        if (data.user) setCurrentEmail(data.user.email ?? "");
      } catch {
        /* ignore */
      }
    })();
  }, [configured]);

  async function onChangePassword(e: FormEvent) {
    e.preventDefault();
    setError("");
    setMsg("");
    setBusy(true);
    try {
      if (newPassword.length < 6) throw new Error("Password must be at least 6 characters.");
      if (newPassword !== confirmPassword) throw new Error("Passwords do not match.");
      const supabase = createBrowserSupabase();
      const { error: err } = await supabase.auth.updateUser({ password: newPassword });
      if (err) throw err;
      setMsg("Password updated. Use the new password next time you sign in.");
      setNewPassword("");
      setConfirmPassword("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update password");
    } finally {
      setBusy(false);
    }
  }

  async function onChangeEmail(e: FormEvent) {
    e.preventDefault();
    setError("");
    setMsg("");
    setBusy(true);
    try {
      if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(newEmail)) throw new Error("Enter a valid email address.");
      const supabase = createBrowserSupabase();
      const { error: err } = await supabase.auth.updateUser({ email: newEmail });
      if (err) throw err;
      setMsg(
        `Confirmation sent to ${newEmail}. Click the link in that email to finish changing your login email.`,
      );
      setNewEmail("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update email");
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      <AdminNav />
      <div className="mx-auto max-w-2xl space-y-6 px-4 py-8">
        <h1 className="text-2xl font-bold">Account</h1>
        {!configured ? (
          <p className="text-sm text-amber-400">
            Add NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY to .env.local, then restart the
            dev server.
          </p>
        ) : null}
        <p className="text-sm text-zinc-400">
          Signed in as <span className="text-white">{currentEmail || "…"}</span>
        </p>
        {msg ? (
          <p className="rounded-lg bg-emerald-500/10 px-3 py-2 text-sm text-emerald-300">{msg}</p>
        ) : null}
        {error ? (
          <p className="rounded-lg bg-red-500/10 px-3 py-2 text-sm text-red-300">{error}</p>
        ) : null}

        <form
          onSubmit={onChangePassword}
          className="space-y-4 rounded-2xl border border-white/10 bg-zinc-900 p-5"
        >
          <h2 className="text-lg font-semibold">Change password</h2>
          <label className="block text-sm">
            New password
            <input
              type="password"
              required
              minLength={6}
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              className="mt-1 w-full rounded-lg border border-white/10 bg-zinc-950 px-3 py-2"
            />
          </label>
          <label className="block text-sm">
            Confirm new password
            <input
              type="password"
              required
              minLength={6}
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className="mt-1 w-full rounded-lg border border-white/10 bg-zinc-950 px-3 py-2"
            />
          </label>
          <button
            type="submit"
            disabled={busy || !configured}
            className="rounded-xl bg-red-600 px-5 py-2 font-semibold disabled:opacity-50"
          >
            Update password
          </button>
        </form>

        <form
          onSubmit={onChangeEmail}
          className="space-y-4 rounded-2xl border border-white/10 bg-zinc-900 p-5"
        >
          <h2 className="text-lg font-semibold">Change email</h2>
          <label className="block text-sm">
            New email
            <input
              type="email"
              required
              value={newEmail}
              onChange={(e) => setNewEmail(e.target.value)}
              className="mt-1 w-full rounded-lg border border-white/10 bg-zinc-950 px-3 py-2"
            />
          </label>
          <p className="text-xs text-zinc-500">
            A confirmation link will be sent to the new email. The change takes effect after you click it.
          </p>
          <button
            type="submit"
            disabled={busy || !configured}
            className="rounded-xl bg-red-600 px-5 py-2 font-semibold disabled:opacity-50"
          >
            Send email change
          </button>
        </form>
      </div>
    </>
  );
}
