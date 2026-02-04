export default function LoginPage() {
  return (
    <main className="container">
      <h1>Entrar</h1>
      <div className="card grid">
        <div>
          <label className="label">Email</label>
          <input className="input" type="email" placeholder="voce@email.com" />
        </div>
        <div>
          <label className="label">Senha</label>
          <input className="input" type="password" />
        </div>
        <button className="button">Entrar</button>
      </div>
    </main>
  );
}
