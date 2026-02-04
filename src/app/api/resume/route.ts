import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { evaluateResume } from "@/lib/resume";

export async function POST(request: NextRequest) {
  const formData = await request.formData();
  const userId = formData.get("userId")?.toString();
  const file = formData.get("file") as File | null;
  const rawText = formData.get("resumeText")?.toString() ?? "";

  if (!userId) {
    return NextResponse.json({ error: "userId obrigatorio" }, { status: 400 });
  }

  let extractedText = rawText;
  let fileName = "resume.txt";

  if (file) {
    fileName = file.name;
    const buffer = Buffer.from(await file.arrayBuffer());

    // TODO: substituir por parser de PDF (ex: pdf-parse) para extrair texto real
    extractedText = buffer.toString("utf-8");
  }

  const evaluation = await evaluateResume(extractedText);

  const resume = await prisma.resume.create({
    data: {
      userId,
      fileName,
      extractedText,
      score: evaluation.score,
      notes: evaluation.improvements.join("\n")
    }
  });

  return NextResponse.json({ resume, evaluation }, { status: 201 });
}
