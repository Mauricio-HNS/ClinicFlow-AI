"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

export default function LoginPage() {
  const [message, setMessage] = useState("");
  const router = useRouter();

  async function handleLogin(formData: FormData) {
    const payload = Object.fromEntries(formData.entries());
    const res = await fetch("/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    if (res.ok) {
      setMessage("Login realizado");
      router.push("/");
      return;
    }

    const data = await res.json().catch(() => ({}));
    setMessage(data.error || "Falha no login");
  }

  return (
    <main className="container">
      <h1>Entrar</h1>
      <form className="card grid" action={handleLogin}>
        <div>
          <label className="label">Email</label>
          <input className="input" name="email" type="email" placeholder="voce@email.com" required />
        </div>
        <div>
          <label className="label">Senha</label>
          <input className="input" name="password" type="password" required />
        </div>
        <button className="button" type="submit">Entrar</button>
        {message ? <p>{message}</p> : null}
      </form>
    </main>
  );
}
