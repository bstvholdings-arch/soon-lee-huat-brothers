"use client";

import { FormEvent, useEffect, useState } from "react";
import { createAnonClient, isSupabaseConfigured } from "@/lib/supabase/client";
import { useLocale } from "./locale-provider";
import type { Feedback } from "@/lib/types";

function Stars({ value, onChange }: { value: number; onChange?: (n: number) => void }) {
  return (
    <div className="flex gap-1" aria-label="rating">
      {[1, 2, 3, 4, 5].map((n) => {
        const active = n <= value;
        const btn = (
          <span
            className={active ? "text-red-600" : "text-zinc-300"}
            aria-hidden="true"
          >
            ★
          </span>
        );
        return onChange ? (
          <button
            type="button"
            key={n}
            onClick={() => onChange(n)}
            className="text-xl leading-none"
            aria-label={`${n} star`}
          >
            {btn}
          </button>
        ) : (
          <span key={n} className="text-xl leading-none">
            {btn}
          </span>
        );
      })}
    </div>
  );
}

export function FeedbackSection() {
  const { locale, t } = useLocale();
  const configured = isSupabaseConfigured();
  const [items, setItems] = useState<Feedback[]>([]);
  const [name, setName] = useState("");
  const [message, setMessage] = useState("");
  const [rating, setRating] = useState(0);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [done, setDone] = useState(false);

  async function loadApproved() {
    if (!configured) return;
    const supabase = createAnonClient();
    if (!supabase) return;
    const { data, error: qErr } = await supabase
      .from("feedback")
      .select("id, name, rating, message, status, created_at")
      .eq("status", "approved")
      .order("created_at", { ascending: false });
    if (!qErr) setItems((data ?? []) as Feedback[]);
  }

  useEffect(() => {
    void loadApproved();
  }, [configured]);

  async function submit(e: FormEvent) {
    e.preventDefault();
    setError("");
    if (!name.trim() || !message.trim()) {
      setError(t("feedbackRequired"));
      return;
    }
    setBusy(true);
    try {
      const supabase = createAnonClient();
      if (!supabase) throw new Error("Supabase not configured");
      const { error: iErr } = await supabase.from("feedback").insert({
        name: name.trim(),
        message: message.trim(),
        rating: rating || null,
        status: "pending",
      });
      if (iErr) throw iErr;
      setName("");
      setMessage("");
      setRating(0);
      setDone(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to submit");
    } finally {
      setBusy(false);
    }
  }

  return (
    <section className="rounded-2xl border border-zinc-200 bg-white p-6">
      <h2 className="text-xl font-semibold text-zinc-900">{t("feedbackTitle")}</h2>
      <p className="mt-2 text-sm text-zinc-500">{t("feedbackIntro")}</p>

      {done ? (
        <p className="mt-4 rounded-lg bg-zinc-100 px-3 py-2 text-sm text-zinc-700">
          {t("feedbackThanks")}
        </p>
      ) : (
        <form onSubmit={submit} className="mt-4 space-y-3">
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder={t("feedbackName")}
            className="w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-zinc-900"
          />
          <div className="flex items-center gap-2">
            <span className="text-sm text-zinc-500">{t("feedbackRating")}</span>
            <Stars value={rating} onChange={setRating} />
          </div>
          <textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder={t("feedbackMessage")}
            rows={3}
            className="w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-zinc-900"
          />
          {error ? <p className="text-sm text-red-600">{error}</p> : null}
          <button
            type="submit"
            disabled={busy}
            className="rounded-xl bg-red-600 px-4 py-2 text-sm font-semibold text-white hover:bg-red-500 disabled:opacity-50"
          >
            {busy ? t("feedbackSubmitting") : t("feedbackSubmit")}
          </button>
        </form>
      )}

      <div className="mt-6 space-y-3">
        {items.length === 0 ? (
          <p className="text-sm text-zinc-500">{t("feedbackEmpty")}</p>
        ) : (
          items.map((f) => (
            <div key={f.id} className="rounded-xl border border-zinc-200 bg-white p-4">
              <div className="flex items-center justify-between gap-2">
                <p className="font-semibold text-zinc-900">{f.name}</p>
                {f.rating ? <Stars value={f.rating} /> : null}
              </div>
              <p className="mt-1 whitespace-pre-wrap text-sm text-zinc-700">{f.message}</p>
              <p className="mt-1 text-xs text-zinc-400">
                {new Date(f.created_at).toLocaleDateString(locale)}
              </p>
            </div>
          ))
        )}
      </div>
    </section>
  );
}
