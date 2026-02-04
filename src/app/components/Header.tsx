"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

export default function Header() {
  const [user, setUser] = useState<{ id: string; name: string | null } | null>(null);

  useEffect(() => {
    fetch("/api/auth/me")
      .then((res) => (res.ok ? res.json() : null))
      .then((data) => setUser(data?.user ?? null))
      .catch(() => setUser(null));
  }, []);

  return (
    <header className="topbar">
      <div className="topbar-inner">
        <div className="brand">
          <span className="brand-dot" />
          Empleos Finder
        </div>
        <nav className="nav">
          <Link href="/">Buscar</Link>
          {user ? <Link href="/resumes">Curriculos</Link> : null}
          {user ? <Link href="/dashboard">Painel</Link> : null}
      {user ? (
            <>
              <span>Ola, {user.name ?? "usuario"}</span>
              <button
                className="link-button"
                onClick={async () => {
                  await fetch("/api/auth/logout", { method: "POST" });
                  setUser(null);
                  window.location.href = "/";
                }}
              >
                Sair
              </button>
            </>
          ) : (
            <>
              <Link href="/login">Entrar</Link>
              <Link href="/register">Criar conta</Link>
            </>
          )}
        </nav>
      </div>
    </header>
  );
}
