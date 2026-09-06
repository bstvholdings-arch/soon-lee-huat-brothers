import { NextRequest, NextResponse } from "next/server";
import { getApiKey, validateApiKey, touchApiKey } from "@/lib/api-auth";
import { getParts } from "@/lib/queries";

export async function GET(req: NextRequest) {
  const key = getApiKey(req);
  if (!(await validateApiKey(key))) {
    return NextResponse.json({ error: "Unauthorized: invalid or missing API key" }, { status: 401 });
  }
  if (key) void touchApiKey(key);

  const parts = await getParts();
  return NextResponse.json({ parts: parts ?? [] });
}
