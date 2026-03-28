import { startTransition, useEffect, useState, type FormEvent } from "react";

const API_BASE_URL = "http://127.0.0.1:5057";
const navItems = ["Dashboard", "Patients", "Scheduling", "Records", "Finance", "Automation"] as const;
const automations = [
  "AI patient summaries before consultation",
  "Smart reminder copy for WhatsApp",
  "Risk scoring for possible no-shows",
  "Operational dashboard across clinic units"
];

type NavItem = (typeof navItems)[number];

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

type Professional = {
  id: string;
  fullName: string;
  specialty: string;
  licenseNumber: string;
  appointmentDurationMinutes: number;
  active: boolean;
};

type PatientSummary = {
  patientId: string;
  clinicalSummary: string;
  attentionPoints: string;
  suggestedNextSteps: string;
};

type PatientForm = {
  fullName: string;
  birthDate: string;
  gender: string;
  phone: string;
  email: string;
  document: string;
  insurance: string;
  notes: string;
};

type AppointmentForm = {
  patientId: string;
  professionalId: string;
  clinicUnitName: string;
  startAtUtc: string;
  notes: string;
};

const appointmentStatusOptions = [
  { value: 1, label: "Scheduled" },
  { value: 2, label: "Confirmed" },
  { value: 3, label: "In progress" },
  { value: 4, label: "Completed" },
  { value: 5, label: "Cancelled" },
  { value: 6, label: "No-show" }
];

const defaultSummary: DashboardSummary = {
  appointmentsToday: 0,
  confirmedAppointments: 0,
  revenueMonth: 0,
  noShowRate: 0,
  activePatients: 0,
  activeProfessionals: 0
};

const emptyPatientForm: PatientForm = {
  fullName: "",
  birthDate: "",
  gender: "Female",
  phone: "",
  email: "",
  document: "",
  insurance: "",
  notes: ""
};

const emptyAppointmentForm: AppointmentForm = {
  patientId: "",
  professionalId: "",
  clinicUnitName: "Madrid Central",
  startAtUtc: "",
  notes: ""
};

async function fetchJson<T>(path: string, options?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE_URL}${path}`, options);

  if (!response.ok) {
    const message = await response.text();
    throw new Error(message || `API request failed with status ${response.status}`);
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

function toUtcIso(localDateTime: string) {
  return new Date(localDateTime).toISOString();
}

export function App() {
  const [activeView, setActiveView] = useState<NavItem>("Dashboard");
  const [session, setSession] = useState<Session | null>(null);
  const [summary, setSummary] = useState<DashboardSummary>(defaultSummary);
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [patients, setPatients] = useState<Patient[]>([]);
  const [professionals, setProfessionals] = useState<Professional[]>([]);
  const [patientSummary, setPatientSummary] = useState<PatientSummary | null>(null);
  const [selectedPatientId, setSelectedPatientId] = useState<string | null>(null);
  const [patientForm, setPatientForm] = useState<PatientForm>(emptyPatientForm);
  const [appointmentForm, setAppointmentForm] = useState<AppointmentForm>(emptyAppointmentForm);
  const [loading, setLoading] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [isSavingPatient, setIsSavingPatient] = useState(false);
  const [isSavingAppointment, setIsSavingAppointment] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [lastUpdated, setLastUpdated] = useState<string | null>(null);

  useEffect(() => {
    void refreshData();
  }, []);

  async function ensureSession() {
    if (session) {
      return session;
    }

    const currentSession = await fetchJson<Session>("/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        email: "admin@clinicflow.ai",
        password: "demo",
        tenantSlug: "demo-clinic"
      })
    });

    setSession(currentSession);
    return currentSession;
  }

  async function refreshData() {
    setLoading((current) => current && !session);
    setIsRefreshing(true);
    setError(null);

    try {
      const currentSession = await ensureSession();
      const headers = {
        "Content-Type": "application/json",
        "X-Tenant-Id": currentSession.tenantId
      };

      const [dashboardData, appointmentsData, patientsData, professionalsData] = await Promise.all([
        fetchJson<DashboardSummary>("/api/dashboard/summary", { headers }),
        fetchJson<Appointment[]>("/api/appointments", { headers }),
        fetchJson<Patient[]>("/api/patients", { headers }),
        fetchJson<Professional[]>("/api/professionals", { headers })
      ]);

      const preferredPatientId = selectedPatientId ?? patientsData[0]?.id ?? null;
      const aiSummary = preferredPatientId
        ? await fetchJson<PatientSummary>(`/api/ai/patient-summary/${preferredPatientId}`, {
            method: "POST",
            headers
          })
        : null;

      startTransition(() => {
        setSummary(dashboardData);
        setAppointments(appointmentsData);
        setPatients(patientsData);
        setProfessionals(professionalsData);
        setPatientSummary(aiSummary);
        setSelectedPatientId(preferredPatientId);
        setAppointmentForm((current) => ({
          ...current,
          patientId: current.patientId || patientsData[0]?.id || "",
          professionalId: current.professionalId || professionalsData[0]?.id || ""
        }));
        setLastUpdated(new Date().toLocaleTimeString("en-GB", {
          hour: "2-digit",
          minute: "2-digit"
        }));
      });
    } catch (refreshError) {
      setError(refreshError instanceof Error ? refreshError.message : "Unable to load data.");
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
    setError(null);

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

  async function handleCreatePatient(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!session) {
      return;
    }

    setIsSavingPatient(true);
    setError(null);
    setSuccessMessage(null);

    try {
      await fetchJson<Patient>("/api/patients", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Tenant-Id": session.tenantId
        },
        body: JSON.stringify(patientForm)
      });

      setPatientForm(emptyPatientForm);
      setSuccessMessage("Patient created successfully.");
      await refreshData();
      setActiveView("Patients");
    } catch (createError) {
      setError(createError instanceof Error ? createError.message : "Unable to create patient.");
    } finally {
      setIsSavingPatient(false);
    }
  }

  async function handleCreateAppointment(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!session || !appointmentForm.patientId || !appointmentForm.professionalId || !appointmentForm.startAtUtc) {
      setError("Patient, professional and start time are required.");
      return;
    }

    setIsSavingAppointment(true);
    setError(null);
    setSuccessMessage(null);

    try {
      await fetchJson<Appointment>("/api/appointments", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Tenant-Id": session.tenantId
        },
        body: JSON.stringify({
          ...appointmentForm,
          startAtUtc: toUtcIso(appointmentForm.startAtUtc)
        })
      });

      setAppointmentForm((current) => ({
        ...emptyAppointmentForm,
        clinicUnitName: current.clinicUnitName,
        patientId: current.patientId,
        professionalId: current.professionalId
      }));
      setSuccessMessage("Appointment created successfully.");
      await refreshData();
      setActiveView("Scheduling");
    } catch (createError) {
      setError(createError instanceof Error ? createError.message : "Unable to create appointment.");
    } finally {
      setIsSavingAppointment(false);
    }
  }

  async function handleUpdateAppointmentStatus(appointmentId: string, status: number) {
    if (!session) {
      return;
    }

    setError(null);
    setSuccessMessage(null);

    try {
      await fetchJson<Appointment>(`/api/appointments/${appointmentId}/status`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          "X-Tenant-Id": session.tenantId
        },
        body: JSON.stringify({
          status,
          cancellationReason: status === 5 ? "Cancelled from dashboard UI" : null
        })
      });

      setSuccessMessage("Appointment status updated.");
      await refreshData();
    } catch (updateError) {
      setError(updateError instanceof Error ? updateError.message : "Unable to update appointment.");
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

  const selectedPatient = patients.find((patient) => patient.id === selectedPatientId) ?? null;

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
          {navItems.map((item) => (
            <button
              className={item === activeView ? "nav-item active nav-button" : "nav-item nav-button"}
              key={item}
              onClick={() => setActiveView(item)}
              type="button"
            >
              {item}
            </button>
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
            <h1>
              {activeView === "Dashboard" && "Run a premium clinic operation with AI in the workflow."}
              {activeView === "Patients" && "Manage patient CRM with context-rich records."}
              {activeView === "Scheduling" && "Book appointments with live professionals and conflict-aware slots."}
              {activeView !== "Dashboard" && activeView !== "Patients" && activeView !== "Scheduling" && "ClinicFlow AI module preview."}
            </h1>
          </div>
          <div className="topbar-actions">
            <a className="ghost-link" href={`${API_BASE_URL}/health`} target="_blank" rel="noreferrer">
              API health
            </a>
            <button onClick={() => void refreshData()}>{isRefreshing ? "Refreshing..." : "Refresh data"}</button>
          </div>
        </header>

        <div className="status-strip">
          <span className="pill teal">{loading ? "Loading live data" : "Live backend connected"}</span>
          {lastUpdated ? <span className="muted">Last sync {lastUpdated}</span> : null}
          {successMessage ? <span className="success-text">{successMessage}</span> : null}
          {error ? <span className="error-text">{error}</span> : null}
        </div>

        {activeView === "Dashboard" ? (
          <>
            <section className="hero-grid">
              <article className="hero-panel">
                <div className="hero-copy">
                  <span className="eyebrow">Today at {appointments[0]?.clinicUnitName ?? "Madrid Central"}</span>
                  <h2>Scheduling, CRM, SOAP and financial clarity in one calm interface.</h2>
                  <p>
                    The dashboard below is fed by the ClinicFlow API seed, including appointments,
                    patient CRM and operational metrics from the backend.
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
                  <p className="summary-name">{selectedPatient?.fullName ?? "No patient selected"}</p>
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
                            <select
                              className="status-select"
                              value={item.status}
                              onChange={(event) => void handleUpdateAppointmentStatus(item.id, Number(event.target.value))}
                            >
                              {appointmentStatusOptions.map((option) => (
                                <option key={option.value} value={option.value}>{option.label}</option>
                              ))}
                            </select>
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
          </>
        ) : null}

        {activeView === "Patients" ? (
          <section className="workspace-grid secondary">
            <article className="panel form-panel">
              <div className="panel-header">
                <div>
                  <p className="section-kicker">Create patient</p>
                  <h3>Reception workflow</h3>
                </div>
              </div>

              <form className="module-form" onSubmit={(event) => void handleCreatePatient(event)}>
                <label>
                  Full name
                  <input value={patientForm.fullName} onChange={(event) => setPatientForm({ ...patientForm, fullName: event.target.value })} required />
                </label>
                <label>
                  Birth date
                  <input type="date" value={patientForm.birthDate} onChange={(event) => setPatientForm({ ...patientForm, birthDate: event.target.value })} required />
                </label>
                <label>
                  Gender
                  <select value={patientForm.gender} onChange={(event) => setPatientForm({ ...patientForm, gender: event.target.value })}>
                    <option>Female</option>
                    <option>Male</option>
                    <option>Other</option>
                  </select>
                </label>
                <label>
                  Phone
                  <input value={patientForm.phone} onChange={(event) => setPatientForm({ ...patientForm, phone: event.target.value })} required />
                </label>
                <label>
                  Email
                  <input type="email" value={patientForm.email} onChange={(event) => setPatientForm({ ...patientForm, email: event.target.value })} required />
                </label>
                <label>
                  Document
                  <input value={patientForm.document} onChange={(event) => setPatientForm({ ...patientForm, document: event.target.value })} required />
                </label>
                <label>
                  Insurance
                  <input value={patientForm.insurance} onChange={(event) => setPatientForm({ ...patientForm, insurance: event.target.value })} />
                </label>
                <label className="full-span">
                  Notes
                  <textarea value={patientForm.notes} onChange={(event) => setPatientForm({ ...patientForm, notes: event.target.value })} rows={4} />
                </label>
                <button type="submit">{isSavingPatient ? "Saving..." : "Create patient"}</button>
              </form>
            </article>

            <article className="panel patient-panel">
              <div className="panel-header">
                <div>
                  <p className="section-kicker">Patient CRM</p>
                  <h3>Live patient list</h3>
                </div>
                <span className="pill blue">{patients.length} patients</span>
              </div>

              <div className="patient-list">
                {patients.map((patient) => (
                  <div className={`patient-card ${selectedPatientId === patient.id ? "selected" : ""}`} key={patient.id}>
                    <div>
                      <strong>{patient.fullName}</strong>
                      <span>{patient.insurance || "Private"} · {patient.gender}</span>
                    </div>
                    <p>{patient.notes}</p>
                    <p className="muted">{patient.email} · {patient.phone}</p>
                    <button type="button" onClick={() => void loadPatientSummary(patient.id)}>
                      {selectedPatientId === patient.id ? "AI summary loaded" : "Generate AI summary"}
                    </button>
                  </div>
                ))}
              </div>
            </article>
          </section>
        ) : null}

        {activeView === "Scheduling" ? (
          <section className="workspace-grid secondary">
            <article className="panel form-panel">
              <div className="panel-header">
                <div>
                  <p className="section-kicker">Create appointment</p>
                  <h3>Book a real consultation</h3>
                </div>
              </div>

              <form className="module-form" onSubmit={(event) => void handleCreateAppointment(event)}>
                <label>
                  Patient
                  <select value={appointmentForm.patientId} onChange={(event) => setAppointmentForm({ ...appointmentForm, patientId: event.target.value })} required>
                    <option value="">Select patient</option>
                    {patients.map((patient) => (
                      <option key={patient.id} value={patient.id}>{patient.fullName}</option>
                    ))}
                  </select>
                </label>
                <label>
                  Professional
                  <select value={appointmentForm.professionalId} onChange={(event) => setAppointmentForm({ ...appointmentForm, professionalId: event.target.value })} required>
                    <option value="">Select professional</option>
                    {professionals.map((professional) => (
                      <option key={professional.id} value={professional.id}>{professional.fullName} · {professional.specialty}</option>
                    ))}
                  </select>
                </label>
                <label>
                  Clinic unit
                  <input value={appointmentForm.clinicUnitName} onChange={(event) => setAppointmentForm({ ...appointmentForm, clinicUnitName: event.target.value })} required />
                </label>
                <label>
                  Start time
                  <input type="datetime-local" value={appointmentForm.startAtUtc} onChange={(event) => setAppointmentForm({ ...appointmentForm, startAtUtc: event.target.value })} required />
                </label>
                <label className="full-span">
                  Notes
                  <textarea value={appointmentForm.notes} onChange={(event) => setAppointmentForm({ ...appointmentForm, notes: event.target.value })} rows={4} />
                </label>
                <button type="submit">{isSavingAppointment ? "Saving..." : "Create appointment"}</button>
              </form>
            </article>

            <article className="panel schedule-panel">
              <div className="panel-header">
                <div>
                  <p className="section-kicker">Live schedule</p>
                  <h3>Appointments from backend</h3>
                </div>
                <span className="pill orange">{appointments.length} bookings</span>
              </div>

              <div className="timeline">
                {appointments.map((item) => (
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
                        <select
                          className="status-select"
                          value={item.status}
                          onChange={(event) => void handleUpdateAppointmentStatus(item.id, Number(event.target.value))}
                        >
                          {appointmentStatusOptions.map((option) => (
                            <option key={option.value} value={option.value}>{option.label}</option>
                          ))}
                        </select>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </article>
          </section>
        ) : null}

        {activeView !== "Dashboard" && activeView !== "Patients" && activeView !== "Scheduling" ? (
          <section className="workspace-grid">
            <article className="panel insight-panel">
              <div className="panel-header">
                <div>
                  <p className="section-kicker">{activeView}</p>
                  <h3>Module planned next</h3>
                </div>
              </div>
              <div className="insight-stack">
                <div className="insight-card">
                  <strong>Foundation ready</strong>
                  <p>This area can now be implemented on top of the same tenant-aware API session.</p>
                </div>
                <div className="insight-card">
                  <strong>Current milestone</strong>
                  <p>Patients and scheduling are already connected, which proves the end-to-end product loop.</p>
                </div>
              </div>
            </article>
          </section>
        ) : null}

        <section className="workspace-grid secondary">
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
                <strong>Frontend now performs real writes</strong>
                <p>Reception can create patients and consultations from the UI using the ClinicFlow API.</p>
              </div>
            </div>
          </article>

          <article className="panel hero-ai">
            <div className="ai-header">
              <div>
                <p className="section-kicker">Live data footprint</p>
                <h3>Current connected modules</h3>
              </div>
            </div>
            <div className="automation-list">
              <div className="automation-item"><span className="automation-dot" /><p>Dashboard summary</p></div>
              <div className="automation-item"><span className="automation-dot" /><p>Patients list and creation</p></div>
              <div className="automation-item"><span className="automation-dot" /><p>Scheduling list and creation</p></div>
              <div className="automation-item"><span className="automation-dot" /><p>Patient AI summary</p></div>
            </div>
          </article>
        </section>
      </section>
    </main>
  );
}
