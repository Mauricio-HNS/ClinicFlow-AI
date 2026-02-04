import { redirect } from "next/navigation";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

export default async function DashboardPage() {
  const user = await getCurrentUser();
  if (!user) redirect("/login");

  const [resumes, jobsCreated, reviews, company] = await Promise.all([
    prisma.resume.findMany({
      where: { userId: user.id },
      orderBy: { createdAt: "desc" }
    }),
    prisma.job.findMany({
      where: { createdById: user.id },
      include: { company: true },
      orderBy: { createdAt: "desc" }
    }),
    prisma.companyReview.findMany({
      where: { userId: user.id },
      include: { company: true },
      orderBy: { createdAt: "desc" }
    }),
    user.role === "COMPANY" && user.companyId
      ? prisma.company.findUnique({
          where: { id: user.companyId },
          include: { reviews: true, jobs: true }
        })
      : Promise.resolve(null)
  ]);

  return (
    <main className="container">
      <h1>Painel</h1>
      <p>Ola, {user.name ?? user.email}!</p>

      {user.role === "COMPANY" ? (
        <section className="grid">
          <h2 className="section-title">Minha empresa</h2>
          <div className="grid grid-2">
            <article className="card">
              <h3>{company?.name ?? "Empresa nao vinculada"}</h3>
              <p>
                Avaliacao media:{" "}
                {company?.reviews.length
                  ? (
                      company.reviews.reduce((sum, r) => sum + r.stars, 0) /
                      company.reviews.length
                    ).toFixed(2)
                  : "Sem avaliacoes"}
              </p>
              <p>
                Score 0-10:{" "}
                {company?.reviews.length
                  ? (
                      company.reviews.reduce((sum, r) => sum + r.score, 0) /
                      company.reviews.length
                    ).toFixed(2)
                  : "Sem avaliacoes"}
              </p>
              <p>Vagas ativas: {company?.jobs.length ?? 0}</p>
            </article>
          </div>
        </section>
      ) : null}

      <section className="grid">
        <h2 className="section-title">Meus curriculos</h2>
        <div className="grid grid-2">
          {resumes.length === 0 ? (
            <article className="card">Nenhum curriculo enviado.</article>
          ) : (
            resumes.map((resume) => (
              <article key={resume.id} className="card">
                <h3>{resume.fileName}</h3>
                <p>Nota: {resume.score ?? "-"}/100</p>
              </article>
            ))
          )}
        </div>
      </section>

      <section className="grid">
        <h2 className="section-title">Vagas cadastradas</h2>
        <div className="grid grid-2">
          {jobsCreated.length === 0 ? (
            <article className="card">Nenhuma vaga cadastrada.</article>
          ) : (
            jobsCreated.map((job) => (
              <article key={job.id} className="card">
                <h3>{job.title}</h3>
                <p>{job.company.name}</p>
              </article>
            ))
          )}
        </div>
      </section>

      <section className="grid">
        <h2 className="section-title">Minhas avaliacoes</h2>
        <div className="grid grid-2">
          {reviews.length === 0 ? (
            <article className="card">Nenhuma avaliacao enviada.</article>
          ) : (
            reviews.map((review) => (
              <article key={review.id} className="card">
                <h3>{review.company.name}</h3>
                <p>{review.stars} estrelas · {review.score}/10</p>
              </article>
            ))
          )}
        </div>
      </section>
    </main>
  );
}
