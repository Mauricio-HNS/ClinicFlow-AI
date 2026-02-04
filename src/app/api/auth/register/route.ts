import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { createSession, hashPassword, setAuthCookie } from "@/lib/auth";

export async function POST(request: NextRequest) {
  const body = await request.json();

  const email = String(body.email || "").toLowerCase();
  const password = String(body.password || "");
  const name = body.name ? String(body.name) : null;
  const role = body.role === "COMPANY" ? "COMPANY" : "USER";

  if (!email || !password) {
    return NextResponse.json({ error: "Email e senha obrigatorios" }, { status: 400 });
  }

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    return NextResponse.json({ error: "Email ja cadastrado" }, { status: 409 });
  }

  const passwordHash = await hashPassword(password);
  const user = await prisma.user.create({
    data: { email, passwordHash, name, role }
  });

  const session = await createSession(user.id);
  setAuthCookie(session.token, session.expiresAt);

  return NextResponse.json(
    { user: { id: user.id, email: user.email, name: user.name, role: user.role } },
    { status: 201 }
  );
}
