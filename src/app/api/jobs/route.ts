import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { geocodeLocation } from "@/lib/geocoding";
import { getDistance } from "geolib";
import { computeMatch } from "@/lib/match";
import { getCurrentUser } from "@/lib/auth";

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url);
  const title = searchParams.get("title");
  const minSalary = searchParams.get("minSalary");
  const location = searchParams.get("location");
  const radiusKm = searchParams.get("radiusKm");
  const resumeId = searchParams.get("resumeId");

  const baseJobs = await prisma.job.findMany({
    where: {
      status: "OPEN",
      title: title ? { contains: title, mode: "insensitive" } : undefined,
      minSalary: minSalary ? { gte: Number(minSalary) } : undefined
    },
    include: {
      company: {
        include: {
          reviews: true
        }
      }
    },
    orderBy: { createdAt: "desc" }
  });

  let jobs = baseJobs;

  if (location && radiusKm) {
    const geo = await geocodeLocation(location);
    if (!geo) {
      return NextResponse.json({ jobs: baseJobs, warning: "Localizacao nao encontrada" });
    }

    const radiusMeters = Number(radiusKm) * 1000;
    jobs = jobs.filter((job) => {
      if (job.locationLat == null || job.locationLng == null) return false;
      const distance = getDistance(
        { latitude: geo.lat, longitude: geo.lng },
        { latitude: job.locationLat, longitude: job.locationLng }
      );
      return distance <= radiusMeters;
    });
  }

  let resume = resumeId ? await prisma.resume.findUnique({ where: { id: resumeId } }) : null;
  if (!resume) {
    const user = await getCurrentUser();
    if (user) {
      resume = await prisma.resume.findFirst({
        where: { userId: user.id },
        orderBy: { createdAt: "desc" }
      });
    }
  }

  const jobsWithRatings = jobs.map((job) => {
    const starsAvg =
      job.company.reviews.reduce((sum, r) => sum + r.stars, 0) /
      (job.company.reviews.length || 1);
    const scoreAvg =
      job.company.reviews.reduce((sum, r) => sum + r.score, 0) /
      (job.company.reviews.length || 1);

    return {
      ...job,
      companyRating: {
        starsAvg: Number(starsAvg.toFixed(2)),
        scoreAvg: Number(scoreAvg.toFixed(2))
      }
    };
  });

  if (resume) {
    const limited = jobsWithRatings.slice(0, 10);
    const matches = await Promise.all(
      limited.map(async (job) => {
        const result = await computeMatch({
          resumeText: resume.extractedText,
          jobText: `${job.title}\n${job.description}`
        });
        return { ...job, matchScore: result.score, matchReasons: result.reasons };
      })
    );

    return NextResponse.json({
      jobs: matches,
      warning:
        jobsWithRatings.length > 10
          ? "Match calculado apenas para as 10 primeiras vagas"
          : undefined
    });
  }

  return NextResponse.json({ jobs: jobsWithRatings });
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const user = await getCurrentUser();
  if (!user) {
    return NextResponse.json({ error: "Nao autenticado" }, { status: 401 });
  }
  let locationLat = body.locationLat;
  let locationLng = body.locationLng;

  if ((!locationLat || !locationLng) && body.locationText) {
    const geo = await geocodeLocation(String(body.locationText));
    if (geo) {
      locationLat = geo.lat;
      locationLng = geo.lng;
    }
  }

  const job = await prisma.job.create({
    data: {
      title: body.title,
      description: body.description,
      locationText: body.locationText,
      locationLat,
      locationLng,
      startDate: body.startDate ? new Date(body.startDate) : null,
      minSalary: body.minSalary,
      currency: body.currency ?? "BRL",
      companyId: body.companyId ?? user.companyId ?? undefined,
      createdById: user.id
    }
  });

  return NextResponse.json({ job }, { status: 201 });
}
