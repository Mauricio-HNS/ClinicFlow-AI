import { NextRequest, NextResponse } from "next/server";
import { computeMatch } from "@/lib/match";

export async function POST(request: NextRequest) {
  const body = await request.json();

  const result = await computeMatch({
    resumeText: body.resumeText,
    jobText: body.jobText
  });

  return NextResponse.json(result);
}
