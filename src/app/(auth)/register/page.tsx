export default function RegisterPage() {
  return (
    <main className="container">
      <h1>Criar conta</h1>
      <div className="card grid">
        <div>
          <label className="label">Nome</label>
          <input className="input" placeholder="Seu nome" />
        </div>
        <div>
          <label className="label">Email</label>
          <input className="input" type="email" placeholder="voce@email.com" />
        </div>
        <div>
          <label className="label">Senha</label>
          <input className="input" type="password" />
        </div>
        <button className="button">Cadastrar</button>
      </div>
    </main>
  );
}
