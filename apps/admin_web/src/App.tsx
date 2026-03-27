const metrics = [
  { label: "Appointments today", value: "28", detail: "+12% vs yesterday" },
  { label: "Monthly revenue", value: "EUR 18.4k", detail: "86% collection rate" },
  { label: "No-show risk alerts", value: "6", detail: "2 require manual confirmation" },
  { label: "AI summaries used", value: "43", detail: "Average 18s saved per consultation" }
];

const agenda = [
  { time: "09:00", patient: "Marina Silva", professional: "Dr. Lucas Martins", status: "Confirmed" },
  { time: "10:20", patient: "Joao Pereira", professional: "Dra. Sofia Ramirez", status: "Scheduled" },
  { time: "11:40", patient: "Elena Ruiz", professional: "Dr. Lucas Martins", status: "In progress" }
];

const automations = [
  "WhatsApp confirmations generated with tone and clinic context",
  "Patient history summarized before each consultation",
  "No-show scoring prioritizing extra reminders",
  "Operational dashboard ready for multi-unit expansion"
];

export function App() {
  return (
    <main className="shell">
      <section className="hero">
        <div className="hero-copy">
          <span className="eyebrow">ClinicFlow AI</span>
          <h1>Multi-tenant clinic operations with an AI co-pilot built in.</h1>
          <p>
            A SaaS platform for clinics that combines smart scheduling, patient CRM,
            financial visibility and operational AI flows in one product-ready stack.
          </p>
          <div className="hero-actions">
            <button>Enter demo</button>
            <a href="http://localhost:5057/health" target="_blank" rel="noreferrer">
              API health
            </a>
          </div>
        </div>
        <div className="hero-card">
          <p className="card-label">AI assistant</p>
          <h2>Patient summary</h2>
          <p>
            Marina Silva shows stable progression, recurring blood pressure follow-up
            and good adherence. Recommend confirming a preventive return in 30 days.
          </p>
          <div className="pill-row">
            <span>Cardiology</span>
            <span>Return suggested</span>
            <span>Low urgency</span>
          </div>
        </div>
      </section>

      <section className="grid metrics">
        {metrics.map((metric) => (
          <article className="panel" key={metric.label}>
            <p className="panel-label">{metric.label}</p>
            <strong>{metric.value}</strong>
            <span>{metric.detail}</span>
          </article>
        ))}
      </section>

      <section className="grid content">
        <article className="panel">
          <div className="panel-header">
            <div>
              <p className="panel-label">Today's agenda</p>
              <h3>Operational overview</h3>
            </div>
            <span className="tag">Madrid Central</span>
          </div>
          <div className="agenda-list">
            {agenda.map((item) => (
              <div className="agenda-item" key={`${item.time}-${item.patient}`}>
                <div>
                  <strong>{item.time}</strong>
                  <p>{item.patient}</p>
                </div>
                <div>
                  <p>{item.professional}</p>
                  <span>{item.status}</span>
                </div>
              </div>
            ))}
          </div>
        </article>

        <article className="panel">
          <div className="panel-header">
            <div>
              <p className="panel-label">Why this project is strong</p>
              <h3>Portfolio-grade differentiators</h3>
            </div>
          </div>
          <ul className="feature-list">
            {automations.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>
        </article>
      </section>
    </main>
  );
}
