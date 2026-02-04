export default function Home() {
  return (
    <main className="container">
      <section className="hero">
        <div>
          <h1>Encontre vagas com match inteligente</h1>
          <p>
            Busque por cargo, localizacao, data de inicio, salario minimo e
            equivalencia com seu perfil.
          </p>
        </div>
        <div className="card grid grid-2">
          <div>
            <label className="label">Cargo</label>
            <input className="input" placeholder="Ex: Desenvolvedor Frontend" />
          </div>
          <div>
            <label className="label">Localizacao</label>
            <input className="input" placeholder="Ex: Sao Paulo" />
          </div>
          <div>
            <label className="label">Raio (km)</label>
            <input className="input" type="number" min={0} placeholder="Ex: 25" />
          </div>
          <div>
            <label className="label">Data de inicio</label>
            <input className="input" type="date" />
          </div>
          <div>
            <label className="label">Salario minimo</label>
            <input className="input" type="number" min={0} placeholder="Ex: 4500" />
          </div>
          <div>
            <label className="label">Equivalencia minima (%)</label>
            <input className="input" type="range" min={0} max={100} />
          </div>
          <button className="button">Buscar vagas</button>
        </div>
      </section>

      <section className="grid">
        <h2 className="section-title">Vagas recomendadas</h2>
        <div className="grid grid-2">
          {[1, 2, 3].map((item) => (
            <article key={item} className="card">
              <h3>Frontend React</h3>
              <p>Empresa X · Sao Paulo · R$ 6.500</p>
              <p>Match: 86% · Nota da empresa: 4.5 estrelas (9.1)</p>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}
