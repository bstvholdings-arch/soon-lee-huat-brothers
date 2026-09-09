"use client";

import { createContext, useCallback, useContext, useMemo, useState } from "react";
import { calculateLoan } from "@/lib/loan";
import { formatMYR, formatNumber, whatsappLink } from "@/lib/i18n";
import { useLocale } from "./locale-provider";

type OpenArgs = { price?: number; name?: string };

const LoanContext = createContext<{ openLoan: (args?: OpenArgs) => void } | null>(null);

export function LoanProvider({
  whatsapp,
  children,
}: {
  whatsapp: string;
  children: React.ReactNode;
}) {
  const { t } = useLocale();
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [price, setPrice] = useState(0);
  const [downpayment, setDownpayment] = useState(0);
  const [years, setYears] = useState(3);
  const [rate, setRate] = useState(3.5);

  const openLoan = useCallback((args?: OpenArgs) => {
    const nextPrice = args?.price ?? 0;
    setName(args?.name ?? "");
    setPrice(nextPrice);
    setDownpayment(nextPrice ? Math.round(nextPrice * 0.1) : 0);
    setOpen(true);
  }, []);

  const result = calculateLoan({
    price,
    downpayment,
    years,
    ratePercent: rate,
  });

  const applyHref = whatsappLink(
    whatsapp,
    t("loanWa", {
      name: name || "-",
      price: formatNumber(price),
      down: formatNumber(downpayment),
      years,
      rate,
      monthly: formatNumber(Math.round(result.monthly)),
    }),
  );

  const value = useMemo(() => ({ openLoan }), [openLoan]);

  return (
    <LoanContext.Provider value={value}>
      {children}
      <button
        type="button"
        onClick={() => openLoan()}
        className="fixed bottom-5 right-5 z-40 rounded-full bg-red-600 px-4 py-3 text-sm font-semibold text-white shadow-lg shadow-red-900/40 hover:bg-red-500 md:bottom-8 md:right-8"
      >
        {t("floatingLoan")}
      </button>
      {open ? (
        <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 p-4 sm:items-center">
          <div className="w-full max-w-md rounded-2xl bg-white p-5 text-zinc-900 ring-1 ring-zinc-200">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold">{t("loanTitle")}</h2>
              <button type="button" onClick={() => setOpen(false)} className="text-zinc-500 hover:text-zinc-900">
                {t("close")}
              </button>
            </div>
            <div className="grid gap-3">
              <Field label={t("vehiclePrice")} value={price} onChange={setPrice} />
              <Field label={t("downpayment")} value={downpayment} onChange={setDownpayment} />
              <Field label={t("tenure")} value={years} onChange={setYears} step={1} />
              <Field label={t("interest")} value={rate} onChange={setRate} step={0.1} />
            </div>
            <dl className="mt-5 space-y-2 rounded-xl bg-zinc-50 p-4 text-sm">
              <Row label={t("loanAmount")} value={formatMYR(result.principal)} />
              <Row label={t("totalInterest")} value={formatMYR(result.totalInterest)} />
              <Row label={t("monthly")} value={formatMYR(Math.round(result.monthly))} strong />
            </dl>
            <a
              href={applyHref}
              target="_blank"
              rel="noreferrer"
              className="mt-4 flex w-full items-center justify-center rounded-xl bg-zinc-900 py-3 text-sm font-semibold text-white hover:bg-zinc-700"
            >
              {t("applyWa")}
            </a>
          </div>
        </div>
      ) : null}
    </LoanContext.Provider>
  );
}

export function useLoan() {
  const ctx = useContext(LoanContext);
  if (!ctx) throw new Error("useLoan must be used within LoanProvider");
  return ctx;
}

function Field({
  label,
  value,
  onChange,
  step = 1,
}: {
  label: string;
  value: number;
  onChange: (n: number) => void;
  step?: number;
}) {
  return (
    <label className="block text-sm">
      <span className="mb-1 block text-zinc-500">{label}</span>
      <input
        type="number"
        min={0}
        step={step}
        value={Number.isFinite(value) ? value : 0}
        onChange={(e) => onChange(Number(e.target.value))}
        className="w-full rounded-lg border border-zinc-200 bg-white px-3 py-2 text-zinc-900 outline-none focus:border-zinc-900"
      />
    </label>
  );
}

function Row({ label, value, strong }: { label: string; value: string; strong?: boolean }) {
  return (
    <div className="flex items-center justify-between gap-4">
      <dt className="text-zinc-500">{label}</dt>
      <dd className={strong ? "text-base font-semibold text-zinc-900" : "font-medium"}>{value}</dd>
    </div>
  );
}
