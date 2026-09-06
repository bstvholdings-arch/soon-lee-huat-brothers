import { NextRequest, NextResponse } from "next/server";
import { getApiKey, validateApiKey, touchApiKey } from "@/lib/api-auth";
import { getMotorcycles } from "@/lib/queries";

export async function GET(req: NextRequest) {
  const key = getApiKey(req);
  if (!(await validateApiKey(key))) {
    return NextResponse.json({ error: "Unauthorized: invalid or missing API key" }, { status: 401 });
  }
  if (key) void touchApiKey(key);

  const { searchParams } = new URL(req.url);
  const type = searchParams.get("type"); // "new" | "used" | undefined (all)
  const bikes = await getMotorcycles(type === "new" || type === "used" ? type : undefined);
  return NextResponse.json({ motorcycles: bikes ?? [] });
}
