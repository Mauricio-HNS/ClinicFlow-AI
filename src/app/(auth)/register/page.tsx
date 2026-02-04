"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

export default function RegisterPage() {
  const [message, setMessage] = useState("");
  const router = useRouter();

  async function handleRegister(formData: FormData) {
    const payload = Object.fromEntries(formData.entries());
    const res = await fetch("/api/auth/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    });

    if (res.ok) {
      setMessage("Conta criada");
      router.push("/");
      return;
    }

    const data = await res.json().catch(() => ({}));
    setMessage(data.error || "Falha no cadastro");
  }

  return (
    <main className="container">
      <h1>Criar conta</h1>
      <form className="card grid" action={handleRegister}>
        <div>
          <label className="label">Nome</label>
          <input className="input" name="name" placeholder="Seu nome" />
        </div>
        <div>
          <label className="label">Email</label>
          <input className="input" name="email" type="email" placeholder="voce@email.com" required />
        </div>
        <div>
          <label className="label">Senha</label>
          <input className="input" name="password" type="password" required />
        </div>
        <div>
          <label className="label">Tipo de conta</label>
          <select className="select" name="role" defaultValue="USER">
            <option value="USER">Candidato</option>
            <option value="COMPANY">Empresa</option>
          </select>
        </div>
        <button className="button" type="submit">Cadastrar</button>
        {message ? <p>{message}</p> : null}
      </form>
    </main>
  );
}
