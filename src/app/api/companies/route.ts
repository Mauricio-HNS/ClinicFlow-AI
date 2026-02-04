import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

export async function GET() {
  const companies = await prisma.company.findMany({
    include: { reviews: true }
  });
  return NextResponse.json({ companies });
}

export async function POST(request: NextRequest) {
  const body = await request.json();

  const user = await getCurrentUser();
  if (!user) {
    return NextResponse.json({ error: "Nao autenticado" }, { status: 401 });
  }

  const company = await prisma.company.create({
    data: {
      name: body.name,
      description: body.description,
      website: body.website,
      location: body.location
    }
  });

  if (user.role === "COMPANY") {
    await prisma.user.update({
      where: { id: user.id },
      data: { companyId: company.id }
    });
  }

  return NextResponse.json({ company }, { status: 201 });
}
