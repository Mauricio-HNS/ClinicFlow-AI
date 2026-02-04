import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";

export async function GET() {
  const companies = await prisma.company.findMany({
    include: { reviews: true }
  });
  return NextResponse.json({ companies });
}

export async function POST(request: NextRequest) {
  const body = await request.json();

  const company = await prisma.company.create({
    data: {
      name: body.name,
      description: body.description,
      website: body.website,
      location: body.location
    }
  });

  return NextResponse.json({ company }, { status: 201 });
}
