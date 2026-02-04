import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

export async function POST(request: NextRequest) {
  const body = await request.json();
  const user = await getCurrentUser();

  if (!user) {
    return NextResponse.json({ error: "Nao autenticado" }, { status: 401 });
  }

  const review = await prisma.companyReview.create({
    data: {
      companyId: body.companyId,
      userId: user.id,
      stars: body.stars,
      score: body.score
    }
  });

  return NextResponse.json({ review }, { status: 201 });
}
