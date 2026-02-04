import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";

export async function POST(request: NextRequest) {
  const body = await request.json();

  const review = await prisma.companyReview.create({
    data: {
      companyId: body.companyId,
      userId: body.userId,
      stars: body.stars,
      score: body.score
    }
  });

  return NextResponse.json({ review }, { status: 201 });
}
