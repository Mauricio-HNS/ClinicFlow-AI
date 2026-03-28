const metrics = [
  { label: "Today's consultations", value: "28", trend: "+12%", tone: "teal" },
  { label: "Occupancy rate", value: "84%", trend: "+6%", tone: "orange" },
  { label: "Monthly revenue", value: "EUR 18.4k", trend: "+18%", tone: "blue" },
  { label: "No-show watchlist", value: "6", trend: "-2", tone: "rose" }
];

const timeline = [
  { hour: "09:00", patient: "Marina Silva", professional: "Dr. Lucas Martins", status: "Confirmed", risk: "24%" },
  { hour: "09:40", patient: "Elena Ruiz", professional: "Dr. Lucas Martins", status: "SOAP in progress", risk: "12%" },
  { hour: "10:20", patient: "Joao Pereira", professional: "Dra. Sofia Ramirez", status: "Needs reminder", risk: "74%" },
  { hour: "11:10", patient: "Lucia Gomez", professional: "Dr. Daniel Costa", status: "Checked in", risk: "18%" }
];

const patients = [
  {
    name: "Marina Silva",
    specialty: "Cardiology",
    summary: "Stable follow-up, consistent adherence, preventive return suggested in 30 days.",
    action: "Generate WhatsApp confirmation"
  },
  {
    name: "Joao Pereira",
    specialty: "Dermatology",
    summary: "High no-show probability due to long lead time and missed prior appointment.",
    action: "Escalate manual confirmation"
  }
];

const financeBars = [
  { label: "Mon", value: 56 },
  { label: "Tue", value: 72 },
  { label: "Wed", value: 64 },
  { label: "Thu", value: 88 },
  { label: "Fri", value: 79 }
];

const automations = [
  "AI patient summaries before consultation",
  "Smart reminder copy for WhatsApp",
  "Risk scoring for possible no-shows",
  "Operational dashboard across clinic units"
];

const navItems = ["Dashboard", "Patients", "Scheduling", "Records", "Finance", "Automation"];

export function App() {
  return (
    <main className="app-shell">
      <aside className="sidebar">
        <div className="brand">
          <div className="brand-mark">CF</div>
          <div>
            <p>ClinicFlow AI</p>
            <span>Multi-tenant clinic ops</span>
          </div>
        </div>

        <nav className="sidebar-nav">
          {navItems.map((item, index) => (
            <a className={index === 0 ? "nav-item active" : "nav-item"} href="/" key={item}>
              {item}
            </a>
          ))}
        </nav>

        <div className="login-card">
          <p className="section-kicker">Demo access</p>
          <h3>Clinic admin</h3>
          <p>admin@clinicflow.ai</p>
          <span>Tenant: demo-clinic</span>
        </div>
      </aside>

      <section className="workspace">
        <header className="topbar">
          <div>
            <p className="section-kicker">Operational command center</p>
            <h1>Run a premium clinic operation with AI in the workflow.</h1>
          </div>
          <div className="topbar-actions">
            <a className="ghost-link" href="http://127.0.0.1:5057/health" target="_blank" rel="noreferrer">
              API health
            </a>
            <button>Book appointment</button>
          </div>
        </header>

        <section className="hero-grid">
          <article className="hero-panel">
            <div className="hero-copy">
              <span className="eyebrow">Today at Madrid Central</span>
              <h2>Scheduling, CRM, SOAP and financial clarity in one calm interface.</h2>
              <p>
                Designed to feel like a real vertical SaaS, not a generic dashboard.
                The product highlights high-value clinic workflows and surfaces AI only where it saves time.
              </p>
            </div>

            <div className="stat-grid">
              {metrics.map((metric) => (
                <article className={`metric-card ${metric.tone}`} key={metric.label}>
                  <p>{metric.label}</p>
                  <strong>{metric.value}</strong>
                  <span>{metric.trend} this week</span>
                </article>
              ))}
            </div>
          </article>

          <article className="hero-ai">
            <div className="ai-header">
              <div>
                <p className="section-kicker">AI assistant</p>
                <h3>Pre-consultation summary</h3>
              </div>
              <span className="pill teal">Ready</span>
            </div>

            <div className="summary-block">
              <p className="summary-name">Marina Silva</p>
              <p>
                Stable progression with recurring blood pressure follow-up, high engagement
                and no clinical alerts. Recommend preventive return scheduling and medication review.
              </p>
            </div>

            <div className="summary-tags">
              <span>Cardiology</span>
              <span>Low urgency</span>
              <span>Return in 30 days</span>
            </div>

            <div className="automation-list">
              {automations.map((item) => (
                <div className="automation-item" key={item}>
                  <span className="automation-dot" />
                  <p>{item}</p>
                </div>
              ))}
            </div>
          </article>
        </section>

        <section className="workspace-grid">
          <article className="panel schedule-panel">
            <div className="panel-header">
              <div>
                <p className="section-kicker">Live schedule</p>
                <h3>Front desk timeline</h3>
              </div>
              <span className="pill orange">4 professionals online</span>
            </div>

            <div className="timeline">
              {timeline.map((item) => (
                <div className="timeline-row" key={`${item.hour}-${item.patient}`}>
                  <div className="timeline-time">{item.hour}</div>
                  <div className="timeline-card">
                    <div>
                      <strong>{item.patient}</strong>
                      <p>{item.professional}</p>
                    </div>
                    <div className="timeline-meta">
                      <span className="pill dark">{item.status}</span>
                      <span className="risk">No-show {item.risk}</span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </article>

          <article className="panel finance-panel">
            <div className="panel-header">
              <div>
                <p className="section-kicker">Revenue pulse</p>
                <h3>Collections this week</h3>
              </div>
              <span className="pill blue">86% paid</span>
            </div>

            <div className="finance-bars">
              {financeBars.map((bar) => (
                <div className="bar-column" key={bar.label}>
                  <div className="bar-track">
                    <div className="bar-fill" style={{ height: `${bar.value}%` }} />
                  </div>
                  <span>{bar.label}</span>
                </div>
              ))}
            </div>

            <div className="finance-summary">
              <div>
                <p>Collected</p>
                <strong>EUR 18,420</strong>
              </div>
              <div>
                <p>Pending</p>
                <strong>EUR 2,640</strong>
              </div>
            </div>
          </article>
        </section>

        <section className="workspace-grid secondary">
          <article className="panel patient-panel">
            <div className="panel-header">
              <div>
                <p className="section-kicker">Patient CRM</p>
                <h3>High-context profiles</h3>
              </div>
            </div>

            <div className="patient-list">
              {patients.map((patient) => (
                <div className="patient-card" key={patient.name}>
                  <div>
                    <strong>{patient.name}</strong>
                    <span>{patient.specialty}</span>
                  </div>
                  <p>{patient.summary}</p>
                  <button>{patient.action}</button>
                </div>
              ))}
            </div>
          </article>

          <article className="panel insight-panel">
            <div className="panel-header">
              <div>
                <p className="section-kicker">What makes it strong</p>
                <h3>Portfolio differentiators</h3>
              </div>
            </div>

            <div className="insight-stack">
              <div className="insight-card">
                <strong>Multi-tenant by design</strong>
                <p>Tenant-aware flows, clinic isolation and role-driven dashboards.</p>
              </div>
              <div className="insight-card">
                <strong>Operational AI</strong>
                <p>Summaries, reminders and no-show prediction attached to real workflow points.</p>
              </div>
              <div className="insight-card">
                <strong>Interview-grade narrative</strong>
                <p>Backend depth, product intuition and modern SaaS UX in one repo.</p>
              </div>
            </div>
          </article>
        </section>
      </section>
    </main>
  );
}
