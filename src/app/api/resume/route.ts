import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { evaluateResume } from "@/lib/resume";
import { getCurrentUser } from "@/lib/auth";
import pdf from "pdf-parse";
import { mkdir, unlink, writeFile } from "node:fs/promises";
import path from "node:path";

export async function GET() {
  const user = await getCurrentUser();
  if (!user) {
    return NextResponse.json({ error: "Nao autenticado" }, { status: 401 });
  }

  const resumes = await prisma.resume.findMany({
    where: { userId: user.id },
    orderBy: { createdAt: "desc" }
  });

  return NextResponse.json({ resumes });
}

export async function PATCH(request: NextRequest) {
  const user = await getCurrentUser();
  if (!user) {
    return NextResponse.json({ error: "Nao autenticado" }, { status: 401 });
  }

  const body = await request.json();
  const resumeId = String(body.resumeId || "");
  if (!resumeId) {
    return NextResponse.json({ error: "resumeId obrigatorio" }, { status: 400 });
  }

  await prisma.resume.updateMany({
    where: { userId: user.id },
    data: { isActive: false }
  });

  const owned = await prisma.resume.findFirst({
    where: { id: resumeId, userId: user.id }
  });
  if (!owned) {
    return NextResponse.json({ error: "Curriculo nao encontrado" }, { status: 404 });
  }

  const resume = await prisma.resume.update({
    where: { id: resumeId },
    data: { isActive: true }
  });

  return NextResponse.json({ resume });
}

export async function DELETE(request: NextRequest) {
  const user = await getCurrentUser();
  if (!user) {
    return NextResponse.json({ error: "Nao autenticado" }, { status: 401 });
  }

  const body = await request.json();
  const resumeId = String(body.resumeId || "");
  if (!resumeId) {
    return NextResponse.json({ error: "resumeId obrigatorio" }, { status: 400 });
  }

  const resume = await prisma.resume.findFirst({
    where: { id: resumeId, userId: user.id }
  });
  if (!resume) {
    return NextResponse.json({ error: "Curriculo nao encontrado" }, { status: 404 });
  }

  if (resume.fileUrl) {
    const relPath = resume.fileUrl.startsWith("/")
      ? resume.fileUrl.slice(1)
      : resume.fileUrl;
    const filePath = path.join(process.cwd(), "public", relPath);
    await unlink(filePath).catch(() => null);
  }

  await prisma.resume.delete({ where: { id: resume.id } });

  const nextActive = await prisma.resume.findFirst({
    where: { userId: user.id },
    orderBy: { createdAt: "desc" }
  });
  if (nextActive) {
    await prisma.resume.update({
      where: { id: nextActive.id },
      data: { isActive: true }
    });
  }

  return NextResponse.json({ ok: true });
}

export async function POST(request: NextRequest) {
  const formData = await request.formData();
  const userId = formData.get("userId")?.toString();
  const user = await getCurrentUser();
  const resolvedUserId = userId ?? user?.id;
  const file = formData.get("file") as File | null;
  const rawText = formData.get("resumeText")?.toString() ?? "";

  if (!resolvedUserId) {
    return NextResponse.json({ error: "Nao autenticado" }, { status: 401 });
  }

  let extractedText = rawText;
  let fileName = "resume.txt";
  let fileUrl: string | null = null;

  if (file) {
    if (file.type !== "application/pdf" && !file.name.toLowerCase().endsWith(".pdf")) {
      return NextResponse.json({ error: "Apenas PDF e permitido" }, { status: 400 });
    }
    const maxBytes = 5 * 1024 * 1024;
    if (file.size > maxBytes) {
      return NextResponse.json({ error: "PDF deve ter ate 5MB" }, { status: 400 });
    }

    fileName = file.name;
    const buffer = Buffer.from(await file.arrayBuffer());
    const uploadDir = path.join(process.cwd(), "public", "uploads");
    await mkdir(uploadDir, { recursive: true });
    const safeName = `${resolvedUserId}-${Date.now()}-${fileName.replace(/\s+/g, "_")}`;
    const filePath = path.join(uploadDir, safeName);
    await writeFile(filePath, buffer);
    fileUrl = `/uploads/${safeName}`;

    if (file.type === "application/pdf" || fileName.toLowerCase().endsWith(".pdf")) {
      const parsed = await pdf(buffer);
      extractedText = parsed.text;
    } else {
      extractedText = buffer.toString("utf-8");
    }
  }

  const evaluation = await evaluateResume(extractedText);

  const previous = await prisma.resume.findFirst({
    where: { userId: resolvedUserId, isActive: true }
  });

  const resume = await prisma.resume.create({
    data: {
      userId: resolvedUserId,
      fileName,
      fileUrl,
      extractedText,
      score: evaluation.score,
      notes: evaluation.improvements.join("\n"),
      isActive: true
    }
  });

  if (previous?.fileUrl) {
    const relPath = previous.fileUrl.startsWith("/")
      ? previous.fileUrl.slice(1)
      : previous.fileUrl;
    const oldPath = path.join(process.cwd(), "public", relPath);
    await unlink(oldPath).catch(() => null);
  }

  await prisma.resume.updateMany({
    where: { userId: resolvedUserId },
    data: { isActive: false }
  });
  await prisma.resume.update({
    where: { id: resume.id },
    data: { isActive: true }
  });

  return NextResponse.json({ resume, evaluation }, { status: 201 });
}
