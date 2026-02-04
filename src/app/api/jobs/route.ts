import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const title = searchParams.get("title");
  const minSalary = searchParams.get("minSalary");

  const jobs = await prisma.job.findMany({
    where: {
      status: "OPEN",
      title: title ? { contains: title, mode: "insensitive" } : undefined,
      minSalary: minSalary ? { gte: Number(minSalary) } : undefined
    },
    include: {
      company: true
    },
    orderBy: { createdAt: "desc" }
  });

  return NextResponse.json({ jobs });
}

export async function POST(request: NextRequest) {
  const body = await request.json();

  const job = await prisma.job.create({
    data: {
      title: body.title,
      description: body.description,
      locationText: body.locationText,
      locationLat: body.locationLat,
      locationLng: body.locationLng,
      startDate: body.startDate ? new Date(body.startDate) : null,
      minSalary: body.minSalary,
      currency: body.currency ?? "BRL",
      companyId: body.companyId,
      createdById: body.createdById ?? null
    }
  });

  return NextResponse.json({ job }, { status: 201 });
}
