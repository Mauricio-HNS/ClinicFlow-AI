import { NextRequest, NextResponse } from "next/server";
import { clearAuthCookie, deleteSession } from "@/lib/auth";

export async function POST(request: NextRequest) {
  const token = request.cookies.get("auth_token")?.value;
  if (token) {
    await deleteSession(token);
  }
  clearAuthCookie();

  return NextResponse.json({ ok: true });
}
