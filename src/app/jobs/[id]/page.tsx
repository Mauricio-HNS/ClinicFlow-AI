import { redirect } from "next/navigation";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import ReviewForm from "@/app/components/ReviewForm";

export default async function JobDetailPage({ params }: { params: { id: string } }) {
  const job = await prisma.job.findUnique({
    where: { id: params.id },
    include: { company: { include: { reviews: true } } }
  });

  if (!job) redirect("/");

  const user = await getCurrentUser();

  const starsAvg =
    job.company.reviews.reduce((sum, r) => sum + r.stars, 0) /
    (job.company.reviews.length || 1);
  const scoreAvg =
    job.company.reviews.reduce((sum, r) => sum + r.score, 0) /
    (job.company.reviews.length || 1);

  return (
    <main className="container">
      <h1>{job.title}</h1>
      <p>{job.company.name}</p>
      <p>{job.locationText ?? "Local remoto"}</p>
      <p>
        {job.minSalary ? `${job.currency ?? "EUR"} ${job.minSalary}` : "Salario a combinar"}
      </p>

      <section className="grid">
        <h2 className="section-title">Descricao</h2>
        <article className="card">
          <p>{job.description}</p>
        </article>
      </section>

      <section className="grid">
        <h2 className="section-title">Nota da empresa</h2>
        <div className="card">
          <p>Estrelas: {starsAvg.toFixed(2)}</p>
          <p>Score 0-10: {scoreAvg.toFixed(2)}</p>
        </div>
      </section>

      <section className="grid">
        <h2 className="section-title">Avaliar empresa</h2>
        {user ? (
          <ReviewForm companyId={job.companyId} />
        ) : (
          <div className="card">Entre para avaliar esta empresa.</div>
        )}
      </section>
    </main>
  );
}
