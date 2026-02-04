"use client";

import { useState } from "react";

export default function ReviewForm({ companyId }: { companyId: string }) {
  const [message, setMessage] = useState("");

  async function handleReview(formData: FormData) {
    const payload: Record<string, unknown> = Object.fromEntries(formData.entries());
    payload.companyId = companyId;
    payload.stars = Number(payload.stars);
    payload.score = Number(payload.score);

    const res = await fetch("/api/reviews", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    if (res.ok) {
      setMessage("Avaliacao enviada");
      return;
    }

    const data = await res.json().catch(() => ({}));
    setMessage(data.error || "Falha ao enviar avaliacao");
  }

  return (
    <form className="card grid" action={handleReview}>
      <div>
        <label className="label">Estrelas (1-5)</label>
        <input className="input" name="stars" type="number" min={1} max={5} required />
      </div>
      <div>
        <label className="label">Pontuacao (0-10)</label>
        <input className="input" name="score" type="number" min={0} max={10} step="0.1" required />
      </div>
      <button className="button" type="submit">Enviar avaliacao</button>
      {message ? <p>{message}</p> : null}
    </form>
  );
}
