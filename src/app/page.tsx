"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

type Job = {
  id: string;
  title: string;
  description: string;
  locationText: string | null;
  minSalary: number | null;
  currency: string | null;
  company: { name: string };
  companyRating?: { starsAvg: number; scoreAvg: number };
  matchScore?: number;
};

export default function Home() {
  const [jobs, setJobs] = useState<Job[]>([]);
  const [message, setMessage] = useState("");
  const [user, setUser] = useState<{ id: string; name: string | null; role: string } | null>(null);
  const [companies, setCompanies] = useState<{ id: string; name: string }[]>([]);

  useEffect(() => {
    fetch("/api/auth/me")
      .then((res) => (res.ok ? res.json() : null))
      .then((data) => setUser(data?.user ?? null))
      .catch(() => setUser(null));
  }, []);

  useEffect(() => {
    fetch("/api/companies")
      .then((res) => (res.ok ? res.json() : null))
      .then((data) => setCompanies(data?.companies ?? []))
      .catch(() => setCompanies([]));
  }, []);

  async function handleSearch(formData: FormData) {
    const title = String(formData.get("title") || "");
    const location = String(formData.get("location") || "");
    const radiusKm = String(formData.get("radiusKm") || "");
    const minSalary = String(formData.get("minSalary") || "");
    const resumeId = String(formData.get("resumeId") || "");

    const params = new URLSearchParams();
    if (title) params.set("title", title);
    if (location) params.set("location", location);
    if (radiusKm) params.set("radiusKm", radiusKm);
    if (minSalary) params.set("minSalary", minSalary);
    if (resumeId) params.set("resumeId", resumeId);

    const res = await fetch(`/api/jobs?${params.toString()}`);
    const data = await res.json();
    setJobs(data.jobs || []);
    setMessage(data.warning || "");
  }

  async function handleCreateCompany(formData: FormData) {
    const payload = Object.fromEntries(formData.entries());
    const res = await fetch("/api/companies", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    if (res.status === 401) {
      setMessage("Faça login para cadastrar empresa");
      return;
    }
    setMessage(res.ok ? "Empresa cadastrada" : "Falha ao cadastrar empresa");
  }

  async function handleCreateJob(formData: FormData) {
    const payload: Record<string, unknown> = Object.fromEntries(formData.entries());
    if (payload.minSalary) payload.minSalary = Number(payload.minSalary);
    if (payload.locationLat) payload.locationLat = Number(payload.locationLat);
    if (payload.locationLng) payload.locationLng = Number(payload.locationLng);
    if (user?.id) payload.createdById = user.id;

    const res = await fetch("/api/jobs", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    if (res.status === 401) {
      setMessage("Faça login para cadastrar vaga");
      return;
    }
    setMessage(res.ok ? "Vaga cadastrada" : "Falha ao cadastrar vaga");
  }

  async function handleReview(formData: FormData) {
    const payload: Record<string, unknown> = Object.fromEntries(formData.entries());
    payload.stars = Number(payload.stars);
    payload.score = Number(payload.score);
    if (user?.id) payload.userId = user.id;
    const res = await fetch("/api/reviews", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });
    if (res.status === 401) {
      setMessage("Faça login para avaliar empresa");
      return;
    }
    setMessage(res.ok ? "Avaliacao enviada" : "Falha ao enviar avaliacao");
  }

  async function handleResumeUpload(formData: FormData) {
    if (user?.id) {
      formData.set("userId", user.id);
    }
    const res = await fetch("/api/resume", {
      method: "POST",
      body: formData
    });
    const data = await res.json();
    if (!res.ok) {
      setMessage(data.error || "Falha no upload");
      return;
    }
    setMessage(`Curriculo avaliado: ${data.evaluation?.score ?? 0}/100`);
  }

  return (
    <main className="container">
      <section className="hero">
        <div>
          <h1>Encontre vagas com match inteligente</h1>
          <p>
            Busque por cargo, localizacao, raio em km, salario minimo e receba
            vagas filtradas.
          </p>
          {user ? (
            <p>
              Ola, {user.name ?? "usuario"}! Acesse seu{" "}
              <Link href="/dashboard">painel</Link>.
            </p>
          ) : (
            <p>
              Entre para salvar seu curriculo.{" "}
              <Link href="/login">Login</Link> ·{" "}
              <Link href="/register">Criar conta</Link>
            </p>
          )}
          {message ? <p>{message}</p> : null}
        </div>
        <form className="card grid grid-2" action={handleSearch}>
          <div>
            <label className="label">Cargo</label>
            <input className="input" name="title" placeholder="Ex: Desenvolvedor Frontend" />
          </div>
          <div>
            <label className="label">Localizacao</label>
            <input className="input" name="location" placeholder="Ex: Madrid" />
          </div>
          <div>
            <label className="label">Raio (km)</label>
            <input className="input" name="radiusKm" type="number" min={0} placeholder="Ex: 25" />
          </div>
          <div>
            <label className="label">Salario minimo</label>
            <input className="input" name="minSalary" type="number" min={0} placeholder="Ex: 2500" />
          </div>
          <div>
            <label className="label">Resume ID (opcional)</label>
            <input className="input" name="resumeId" placeholder="Deixe vazio para usar o ultimo envio" />
          </div>
          <button className="button" type="submit">Buscar vagas</button>
        </form>
      </section>

      <section className="grid">
        <h2 className="section-title">Vagas recomendadas</h2>
        <div className="grid grid-2">
          {jobs.length === 0 ? (
            <article className="card">Nenhuma vaga encontrada.</article>
          ) : (
            jobs.map((job) => (
              <article key={job.id} className="card">
                <h3>
                  <Link href={`/jobs/${job.id}`}>{job.title}</Link>
                </h3>
                <p>
                  {job.company?.name} · {job.locationText ?? "Local remoto"} ·{" "}
                  {job.minSalary ? `${job.currency ?? "EUR"} ${job.minSalary}` : "Salario a combinar"}
                </p>
                {typeof job.matchScore === "number" ? (
                  <p>Match: {job.matchScore}%</p>
                ) : null}
                {job.companyRating ? (
                  <p>
                    Nota da empresa: {job.companyRating.starsAvg} estrelas · {job.companyRating.scoreAvg}/10
                  </p>
                ) : null}
              </article>
            ))
          )}
        </div>
      </section>

      <section className="grid">
        <h2 className="section-title">Cadastrar empresa</h2>
        {!user ? (
          <div className="card">
            Entre para cadastrar empresas. <Link href="/login">Login</Link>
          </div>
        ) : user.role !== "COMPANY" ? (
          <div className="card">
            Apenas contas de empresa podem cadastrar empresas.
          </div>
        ) : (
          <form className="card grid grid-2" action={handleCreateCompany}>
            <div>
              <label className="label">Nome</label>
              <input className="input" name="name" required />
            </div>
            <div>
              <label className="label">Localizacao</label>
              <input className="input" name="location" />
            </div>
            <div>
              <label className="label">Website</label>
              <input className="input" name="website" />
            </div>
            <div>
              <label className="label">Descricao</label>
              <textarea className="textarea" name="description" rows={3} />
            </div>
            <button className="button" type="submit">Salvar empresa</button>
          </form>
        )}
      </section>

      <section className="grid">
        <h2 className="section-title">Cadastrar vaga</h2>
        {!user ? (
          <div className="card">
            Entre para cadastrar vagas. <Link href="/login">Login</Link>
          </div>
        ) : user.role !== "COMPANY" ? (
          <div className="card">
            Apenas contas de empresa podem cadastrar vagas.
          </div>
        ) : (
          <form className="card grid grid-2" action={handleCreateJob}>
            <div>
              <label className="label">Empresa</label>
              <select className="select" name="companyId">
                <option value="">Automatica (empresa da sua conta)</option>
                {companies.map((company) => (
                  <option key={company.id} value={company.id}>
                    {company.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="label">Titulo</label>
              <input className="input" name="title" required />
            </div>
            <div>
              <label className="label">Descricao</label>
              <textarea className="textarea" name="description" rows={3} required />
            </div>
            <div>
              <label className="label">Localizacao texto</label>
              <input className="input" name="locationText" placeholder="Madrid" />
            </div>
            <div>
              <label className="label">Latitude (opcional)</label>
              <input className="input" name="locationLat" type="number" step="0.000001" />
            </div>
            <div>
              <label className="label">Longitude (opcional)</label>
              <input className="input" name="locationLng" type="number" step="0.000001" />
            </div>
            <div>
              <label className="label">Salario minimo</label>
              <input className="input" name="minSalary" type="number" min={0} />
            </div>
            <button className="button" type="submit">Salvar vaga</button>
          </form>
        )}
      </section>

      <section className="grid">
        <h2 className="section-title">Avaliar empresa</h2>
        {!user ? (
          <div className="card">
            Entre para avaliar empresas. <Link href="/login">Login</Link>
          </div>
        ) : (
          <form className="card grid grid-2" action={handleReview}>
            <div>
              <label className="label">Empresa</label>
              <select className="select" name="companyId" required>
                <option value="">Selecione</option>
                {companies.map((company) => (
                  <option key={company.id} value={company.id}>
                    {company.name}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="label">Estrelas (1-5)</label>
              <input className="input" name="stars" type="number" min={1} max={5} required />
            </div>
            <div>
              <label className="label">Pontuacao (0-10)</label>
              <input className="input" name="score" type="number" min={0} max={10} step="0.1" required />
            </div>
            <button className="button" type="submit">Enviar avaliacao</button>
          </form>
        )}
      </section>

      <section className="grid">
        <h2 className="section-title">Upload de curriculo</h2>
        {!user ? (
          <div className="card">
            Entre para enviar curriculo. <Link href="/login">Login</Link>
          </div>
        ) : (
          <form className="card grid" action={handleResumeUpload}>
            <div>
              <label className="label">Curriculo PDF</label>
              <input className="input" name="file" type="file" accept="application/pdf" required />
            </div>
            <button className="button" type="submit">Enviar curriculo</button>
          </form>
        )}
      </section>
    </main>
  );
}
