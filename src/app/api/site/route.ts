import { NextRequest, NextResponse } from "next/server";
import { getApiKey, validateApiKey, touchApiKey } from "@/lib/api-auth";
import { getSiteContent } from "@/lib/queries";

export async function GET(req: NextRequest) {
  const key = getApiKey(req);
  if (!(await validateApiKey(key))) {
    return NextResponse.json({ error: "Unauthorized: invalid or missing API key" }, { status: 401 });
  }
  if (key) void touchApiKey(key);

  const content = await getSiteContent();
  const map: Record<string, string> = {};
  for (const row of content ?? []) {
    map[row.section_key] = row.content_en;
  }
  return NextResponse.json({ content: map });
}
