import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const sources = (process.env.INGEST_SOURCES || "")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

const PUBLISH = String(process.env.INGEST_PUBLISH || "false").toLowerCase() === "true";

async function ensureSource(name, type, baseUrl = null) {
  const existing = await prisma.externalJobSource.findUnique({ where: { name } });
  if (existing) return existing;
  return prisma.externalJobSource.create({
    data: { name, type, baseUrl }
  });
}

async function ingestMock() {
  const source = await ensureSource("mock", "mock", "local");
  const items = [
    {
      externalId: "mock-1",
      title: "Frontend React",
      description: "Vaga frontend com React e TypeScript.",
      location: "Madrid",
      minSalary: 2800,
      currency: "EUR",
      companyName: "Empresa Demo"
    },
    {
      externalId: "mock-2",
      title: "Backend Node",
      description: "Node.js, PostgreSQL e APIs.",
      location: "Madrid",
      minSalary: 3200,
      currency: "EUR",
      companyName: "Tech Madrid"
    }
  ];

  for (const item of items) {
    const external = await prisma.externalJob.upsert({
      where: { sourceId_externalId: { sourceId: source.id, externalId: item.externalId } },
      update: {
        title: item.title,
        description: item.description,
        location: item.location,
        minSalary: item.minSalary,
        currency: item.currency,
        companyName: item.companyName,
        raw: item
      },
      create: {
        sourceId: source.id,
        externalId: item.externalId,
        title: item.title,
        description: item.description,
        location: item.location,
        minSalary: item.minSalary,
        currency: item.currency,
        companyName: item.companyName,
        raw: item
      }
    });

    if (PUBLISH) {
      let company = null;
      if (item.companyName) {
        company = await prisma.company.upsert({
          where: { name: item.companyName },
          update: {},
          create: { name: item.companyName }
        });
      }

      await prisma.job.create({
        data: {
          title: item.title,
          description: item.description,
          locationText: item.location,
          minSalary: item.minSalary,
          currency: item.currency,
          companyId: company?.id || (await prisma.company.create({ data: { name: "Empresa externa" } })).id,
          createdById: null
        }
      });

      await prisma.externalJob.update({
        where: { id: external.id },
        data: { companyId: company?.id ?? null }
      });
    }
  }

  await prisma.externalJobSource.update({
    where: { id: source.id },
    data: { lastRunAt: new Date() }
  });
}

async function main() {
  if (sources.length === 0) {
    console.log("Nenhuma fonte configurada. Defina INGEST_SOURCES");
    return;
  }

  for (const source of sources) {
    if (source === "mock") {
      await ingestMock();
    } else {
      console.log(`Fonte nao implementada: ${source}`);
    }
  }
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
