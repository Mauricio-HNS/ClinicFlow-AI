import { startTransition, useEffect, useState } from "react";

const API_BASE_URL = "http://127.0.0.1:5057";

const navItems = ["Dashboard", "Patients", "Scheduling", "Records", "Finance", "Automation"];
const automations = [
  "AI patient summaries before consultation",
  "Smart reminder copy for WhatsApp",
  "Risk scoring for possible no-shows",
  "Operational dashboard across clinic units"
];

type Session = {
  accessToken: string;
  tenantId: string;
  tenantName: string;
  userId: string;
  fullName: string;
  role: string;
};

type DashboardSummary = {
  appointmentsToday: number;
  confirmedAppointments: number;
  revenueMonth: number;
  noShowRate: number;
  activePatients: number;
  activeProfessionals: number;
};

type Appointment = {
  id: string;
  patientId: string;
  patientName: string;
  professionalId: string;
  professionalName: string;
  clinicUnitName: string;
  startAtUtc: string;
  endAtUtc: string;
  status: number;
  noShowRiskScore: number;
};

type Patient = {
  id: string;
  fullName: string;
  birthDate: string;
  gender: string;
  phone: string;
  email: string;
  insurance: string;
  notes: string;
};

type PatientSummary = {
  patientId: string;
  clinicalSummary: string;
  attentionPoints: string;
  suggestedNextSteps: string;
};

const defaultSummary: DashboardSummary = {
  appointmentsToday: 0,
  confirmedAppointments: 0,
  revenueMonth: 0,
  noShowRate: 0,
  activePatients: 0,
  activeProfessionals: 0
};

async function fetchJson<T>(path: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, options);

  if (!response.ok) {
    throw new Error(`API request failed with status ${response.status}`);
  }

  return response.json() as Promise<T>;
}

function formatCurrency(value: number) {
  return new Intl.NumberFormat("en-IE", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0
  }).format(value);
}

function formatTime(date: string) {
  return new Intl.DateTimeFormat("en-GB", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
    timeZone: "UTC"
  }).format(new Date(date));
}

function formatDate(date: string) {
  return new Intl.DateTimeFormat("en-GB", {
    day: "2-digit",
    month: "short",
    year: "numeric"
  }).format(new Date(date));
}

function mapStatus(status: number) {
  switch (status) {
    case 1:
      return "Scheduled";
    case 2:
      return "Confirmed";
    case 3:
      return "In progress";
    case 4:
      return "Completed";
    case 5:
      return "Cancelled";
    case 6:
      return "No-show";
    default:
      return "Unknown";
  }
}

export function App() {
  const [session, setSession] = useState<Session | null>(null);
  const [summary, setSummary] = useState<DashboardSummary>(defaultSummary);
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [patients, setPatients] = useState<Patient[]>([]);
  const [patientSummary, setPatientSummary] = useState<PatientSummary | null>(null);
  const [selectedPatientId, setSelectedPatientId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<string | null>(null);

  useEffect(() => {
    void refreshDashboard();
  }, []);

  async function refreshDashboard() {
    setLoading((current) => current && !session);
    setIsRefreshing(true);
    setError(null);

    try {
      const currentSession = session ?? await fetchJson<Session>("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          email: "admin@clinicflow.ai",
          password: "demo",
          tenantSlug: "demo-clinic"
        })
      });

      if (!session) {
        setSession(currentSession);
      }

      const tenantHeaders = {
        "Content-Type": "application/json",
        "X-Tenant-Id": currentSession.tenantId
      };

      const [dashboardData, appointmentsData, patientsData] = await Promise.all([
        fetchJson<DashboardSummary>("/api/dashboard/summary", { headers: tenantHeaders }),
        fetchJson<Appointment[]>("/api/appointments", { headers: tenantHeaders }),
        fetchJson<Patient[]>("/api/patients", { headers: tenantHeaders })
      ]);

      let aiSummary: PatientSummary | null = patientSummary;
      const preferredPatientId = selectedPatientId ?? patientsData[0]?.id;

      if (preferredPatientId) {
        aiSummary = await fetchJson<PatientSummary>(`/api/ai/patient-summary/${preferredPatientId}`, {
          method: "POST",
          headers: tenantHeaders
        });
      }

      startTransition(() => {
        setSummary(dashboardData);
        setAppointments(appointmentsData);
        setPatients(patientsData);
        setPatientSummary(aiSummary);
        setSelectedPatientId(preferredPatientId ?? null);
        setLastUpdated(new Date().toLocaleTimeString("en-GB", {
          hour: "2-digit",
          minute: "2-digit"
        }));
      });
    } catch (refreshError) {
      setError(refreshError instanceof Error ? refreshError.message : "Unable to load dashboard.");
    } finally {
      setLoading(false);
      setIsRefreshing(false);
    }
  }

  async function loadPatientSummary(patientId: string) {
    if (!session) {
      return;
    }

    setSelectedPatientId(patientId);

    try {
      const summaryResponse = await fetchJson<PatientSummary>(`/api/ai/patient-summary/${patientId}`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Tenant-Id": session.tenantId
        }
      });

      setPatientSummary(summaryResponse);
    } catch (summaryError) {
      setError(summaryError instanceof Error ? summaryError.message : "Unable to load AI summary.");
    }
  }

  const metrics = [
    { label: "Today's consultations", value: String(summary.appointmentsToday), trend: `${summary.confirmedAppointments} confirmed`, tone: "teal" },
    { label: "Occupancy rate", value: `${summary.appointmentsToday === 0 ? 0 : Math.round((summary.confirmedAppointments / summary.appointmentsToday) * 100)}%`, trend: `${summary.activeProfessionals} active professionals`, tone: "orange" },
    { label: "Monthly revenue", value: formatCurrency(summary.revenueMonth), trend: `${summary.activePatients} active patients`, tone: "blue" },
    { label: "No-show watchlist", value: `${summary.noShowRate}%`, trend: "Derived from completed visits", tone: "rose" }
  ];

  const financeBars = [
    { label: "Today", value: Math.min(summary.appointmentsToday * 10, 100) || 8 },
    { label: "Confirmed", value: Math.min(summary.confirmedAppointments * 14, 100) || 12 },
    { label: "Patients", value: Math.min(summary.activePatients * 20, 100) || 16 },
    { label: "Doctors", value: Math.min(summary.activeProfessionals * 24, 100) || 10 },
    { label: "No-show", value: Math.min(Math.round(summary.noShowRate), 100) || 6 }
  ];

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
          <h3>{session?.fullName ?? "Connecting..."}</h3>
          <p>admin@clinicflow.ai</p>
          <span>{session?.tenantName ?? "Tenant: demo-clinic"}</span>
        </div>
      </aside>

      <section className="workspace">
        <header className="topbar">
          <div>
            <p className="section-kicker">Operational command center</p>
            <h1>Run a premium clinic operation with AI in the workflow.</h1>
          </div>
          <div className="topbar-actions">
            <a className="ghost-link" href={`${API_BASE_URL}/health`} target="_blank" rel="noreferrer">
              API health
            </a>
            <button onClick={() => void refreshDashboard()}>{isRefreshing ? "Refreshing..." : "Refresh data"}</button>
          </div>
        </header>

        <div className="status-strip">
          <span className="pill teal">{loading ? "Loading live data" : "Live backend connected"}</span>
          {lastUpdated ? <span className="muted">Last sync {lastUpdated}</span> : null}
          {error ? <span className="error-text">{error}</span> : null}
        </div>

        <section className="hero-grid">
          <article className="hero-panel">
            <div className="hero-copy">
              <span className="eyebrow">Today at {appointments[0]?.clinicUnitName ?? "Madrid Central"}</span>
              <h2>Scheduling, CRM, SOAP and financial clarity in one calm interface.</h2>
              <p>
                The dashboard below is now fed by the actual ClinicFlow API seed, including
                appointments, patient CRM and operational metrics from the backend.
              </p>
            </div>

            <div className="stat-grid">
              {metrics.map((metric) => (
                <article className={`metric-card ${metric.tone}`} key={metric.label}>
                  <p>{metric.label}</p>
                  <strong>{metric.value}</strong>
                  <span>{metric.trend}</span>
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
              <span className="pill teal">{patientSummary ? "Live" : "Waiting"}</span>
            </div>

            <div className="summary-block">
              <p className="summary-name">
                {patients.find((patient) => patient.id === selectedPatientId)?.fullName ?? "No patient selected"}
              </p>
              <p>{patientSummary?.clinicalSummary ?? "Pick a patient card to load an AI summary from the backend."}</p>
            </div>

            <div className="summary-tags">
              <span>{patientSummary?.attentionPoints ?? "Operational summary"}</span>
              <span>{patientSummary?.suggestedNextSteps ?? "Next steps will appear here"}</span>
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
              <span className="pill orange">{summary.activeProfessionals} professionals online</span>
            </div>

            <div className="timeline">
              {appointments.length === 0 ? (
                <div className="empty-state">No appointments loaded yet.</div>
              ) : (
                appointments.map((item) => (
                  <div className="timeline-row" key={item.id}>
                    <div className="timeline-time">{formatTime(item.startAtUtc)}</div>
                    <div className="timeline-card">
                      <div>
                        <strong>{item.patientName}</strong>
                        <p>{item.professionalName}</p>
                        <p className="muted">{formatDate(item.startAtUtc)} · {item.clinicUnitName}</p>
                      </div>
                      <div className="timeline-meta">
                        <span className="pill dark">{mapStatus(item.status)}</span>
                        <span className="risk">No-show {item.noShowRiskScore}%</span>
                      </div>
                    </div>
                  </div>
                ))
              )}
            </div>
          </article>

          <article className="panel finance-panel">
            <div className="panel-header">
              <div>
                <p className="section-kicker">Revenue pulse</p>
                <h3>Live operational metrics</h3>
              </div>
              <span className="pill blue">{summary.confirmedAppointments} confirmed today</span>
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
                <p>Collected this month</p>
                <strong>{formatCurrency(summary.revenueMonth)}</strong>
              </div>
              <div>
                <p>No-show rate</p>
                <strong>{summary.noShowRate}%</strong>
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
              {patients.length === 0 ? (
                <div className="empty-state">No patients loaded yet.</div>
              ) : (
                patients.map((patient) => (
                  <div className={`patient-card ${selectedPatientId === patient.id ? "selected" : ""}`} key={patient.id}>
                    <div>
                      <strong>{patient.fullName}</strong>
                      <span>{patient.insurance || "Private"} · {patient.gender}</span>
                    </div>
                    <p>{patient.notes}</p>
                    <p className="muted">{patient.email} · {patient.phone}</p>
                    <button onClick={() => void loadPatientSummary(patient.id)}>
                      {selectedPatientId === patient.id ? "AI summary loaded" : "Generate AI summary"}
                    </button>
                  </div>
                ))
              )}
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
                <p>Authenticated tenant context is used to fetch dashboard, appointments and CRM data.</p>
              </div>
              <div className="insight-card">
                <strong>Operational AI</strong>
                <p>The AI panel uses a real backend endpoint to summarize the selected patient record.</p>
              </div>
              <div className="insight-card">
                <strong>Backend + frontend integration</strong>
                <p>The dashboard is no longer a mockup. It now consumes live seeded endpoints from ClinicFlow API.</p>
              </div>
            </div>
          </article>
        </section>
      </section>
    </main>
  );
}
