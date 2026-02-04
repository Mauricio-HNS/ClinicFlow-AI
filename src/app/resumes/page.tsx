"use client";

import { useEffect, useMemo, useState } from "react";

type Resume = {
  id: string;
  fileName: string;
  fileUrl: string | null;
  score: number | null;
  notes: string | null;
  isActive: boolean;
  createdAt: string;
};

export default function ResumesPage() {
  const [resumes, setResumes] = useState<Resume[]>([]);
  const [message, setMessage] = useState("");
  const [previewId, setPreviewId] = useState<string | null>(null);

  async function loadResumes() {
    const res = await fetch("/api/resume");
    if (!res.ok) {
      setMessage("Entre para ver seus curriculos");
      return;
    }
    const data = await res.json();
    setResumes(data.resumes || []);
  }

  useEffect(() => {
    loadResumes();
  }, []);

  const activeResume = useMemo(() => resumes.find((r) => r.isActive) ?? null, [resumes]);

  async function handleActivate(resumeId: string) {
    const res = await fetch("/api/resume", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ resumeId })
    });

    if (res.ok) {
      setMessage("Curriculo selecionado");
      setPreviewId(resumeId);
      loadResumes();
      return;
    }

    setMessage("Falha ao selecionar curriculo");
  }

  async function handleDelete(resumeId: string) {
    const ok = window.confirm("Tem certeza que deseja excluir este curriculo?");
    if (!ok) return;

    const res = await fetch("/api/resume", {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ resumeId })
    });

    if (res.ok) {
      setMessage("Curriculo excluido");
      if (previewId === resumeId) setPreviewId(null);
      loadResumes();
      return;
    }

    setMessage("Falha ao excluir curriculo");
  }

  async function handleUpload(formData: FormData) {
    const res = await fetch("/api/resume", {
      method: "POST",
      body: formData
    });
    const data = await res.json();
    if (!res.ok) {
      setMessage(data.error || "Falha no upload");
      return;
    }
    setMessage("Curriculo enviado e selecionado");
    setPreviewId(data.resume?.id ?? null);
    loadResumes();
  }

  return (
    <main className="container">
      <h1>Meus curriculos</h1>
      {message ? <p>{message}</p> : null}

      {activeResume ? (
        <section className="grid">
          <h2 className="section-title">Curriculo ativo</h2>
          <article className="card">
            <div className="card-header">
              <div>
                <h3>{activeResume.fileName}</h3>
                <p>Nota: {activeResume.score ?? "-"}/100</p>
                <p>Enviado em: {new Date(activeResume.createdAt).toLocaleString()}</p>
              </div>
              <span className="badge">Ativo</span>
            </div>
            {activeResume.fileUrl ? (
              <div className="card-actions">
                <a className="button" href={activeResume.fileUrl} target="_blank" rel="noreferrer">
                  Ver PDF
                </a>
                <button className="button button-outline" onClick={() => setPreviewId(activeResume.id)}>
                  Preview
                </button>
              </div>
            ) : null}
          </article>
        </section>
      ) : null}

      <section className="grid">
        <h2 className="section-title">Enviar novo</h2>
        <form className="card grid" action={handleUpload}>
          <div>
            <label className="label">Curriculo PDF</label>
            <input className="input" name="file" type="file" accept="application/pdf" required />
          </div>
          <button className="button" type="submit">Enviar</button>
        </form>
      </section>

      <section className="grid">
        <h2 className="section-title">Lista</h2>
        <div className="grid grid-2">
          {resumes.length === 0 ? (
            <article className="card">Nenhum curriculo encontrado.</article>
          ) : (
            resumes.map((resume) => (
              <article key={resume.id} className={`card ${resume.isActive ? "card-active" : ""}`}>
                <div className="card-header">
                  <div>
                    <h3>{resume.fileName}</h3>
                    <p>Nota: {resume.score ?? "-"}/100</p>
                    <p>Status: {resume.isActive ? <span className="badge">Ativo</span> : "Disponivel"}</p>
                    <p>Enviado em: {new Date(resume.createdAt).toLocaleString()}</p>
                  </div>
                </div>
                {resume.fileUrl ? (
                  <p>
                    <a href={resume.fileUrl} target="_blank" rel="noreferrer">
                      Ver PDF
                    </a>
                  </p>
                ) : null}
                <div className="card-actions">
                  {!resume.isActive ? (
                    <button className="button" onClick={() => handleActivate(resume.id)}>
                      Definir como ativo
                    </button>
                  ) : null}
                  <button className="button button-outline" onClick={() => setPreviewId(resume.id)}>
                    Preview
                  </button>
                  <button className="button button-outline" onClick={() => handleDelete(resume.id)}>
                    Excluir
                  </button>
                </div>
                {resume.notes ? (
                  <details>
                    <summary>Pontos de melhoria</summary>
                    <pre>{resume.notes}</pre>
                  </details>
                ) : null}
              </article>
            ))
          )}
        </div>
      </section>

      {previewId ? (
        <section className="grid">
          <h2 className="section-title">Preview</h2>
          <div className="card">
            <div className="card-actions">
              <button className="button button-outline" onClick={() => setPreviewId(null)}>
                Fechar preview
              </button>
            </div>
            <iframe
              title="Curriculo selecionado"
              src={resumes.find((r) => r.id === previewId)?.fileUrl ?? ""}
              style={{ width: "100%", height: "600px", border: "none" }}
            />
          </div>
        </section>
      ) : null}
    </main>
  );
}
