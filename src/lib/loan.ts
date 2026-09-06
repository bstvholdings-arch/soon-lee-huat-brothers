export type LoanInput = {
  price: number;
  downpayment: number;
  years: number;
  ratePercent: number;
};

export type LoanResult = {
  principal: number;
  totalInterest: number;
  monthly: number;
};

export function calculateLoan({ price, downpayment, years, ratePercent }: LoanInput): LoanResult {
  const principal = Math.max(0, price - downpayment);
  const rate = ratePercent / 100;
  const safeYears = Math.max(0, years);
  const totalInterest = principal * rate * safeYears;
  const months = safeYears * 12;
  const monthly = months > 0 ? (principal + totalInterest) / months : 0;
  return { principal, totalInterest, monthly };
}
