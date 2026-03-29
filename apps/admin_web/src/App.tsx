import { useEffect, useMemo, useState, type FormEvent } from "react";
import { useLanguage } from "./language/LanguageProvider";

const API_BASE_URL = "http://127.0.0.1:5057";
const SESSION_STORAGE_KEY = "clinicflow-admin-session";

type PlatformDashboard = {
  totalClients: number;
  activeClients: number;
  overdueClients: number;
  suspendedClients: number;
  mrr: number;
  expiringThisWeek: number;
};

type PlatformClient = {
  id: string;
  clientCode: string;
  clinicName: string;
  planName: string;
  monthlyAmount: number;
  billingStatus: string;
  dueDate: string;
  daysUntilCutoff: number;
  isSuspended: boolean;
  ownerName: string;
  ownerEmail: string;
  lastPaymentLabel: string;
  notes: string;
};

type PlatformMessage = {
  id: string;
  clientId: string;
  clinicName: string;
  channel: string;
  subject: string;
  body: string;
  sentAtUtc: string;
};

type PlatformAccessMember = {
  id: string;
  clientId: string;
  fullName: string;
  email: string;
  role: string;
  canViewDashboard: boolean;
  canViewBilling: boolean;
  canManagePatients: boolean;
  canManageSchedule: boolean;
  canManageSettings: boolean;
  isActive: boolean;
};

type MessageForm = {
  clientId: string;
  channel: string;
  subject: string;
  body: string;
};

type AccessMemberForm = {
  fullName: string;
  email: string;
  role: string;
  canViewDashboard: boolean;
  canViewBilling: boolean;
  canManagePatients: boolean;
  canManageSchedule: boolean;
  canManageSettings: boolean;
};

type AppRole = "platform_admin" | "clinic_admin" | "staff";

type SessionUser = {
  id: string;
  name: string;
  email: string;
  role: AppRole;
  clientId?: string;
  password: string;
};

type MenuPermission =
  | "dashboard"
  | "clients"
  | "billing"
  | "renewals"
  | "suspensions"
  | "messages"
  | "notes"
  | "alerts"
  | "plans"
  | "reports"
  | "audit"
  | "settings"
  | "clinic_access";

type ClinicView =
  | "dashboard"
  | "agenda"
  | "patients"
  | "doctors"
  | "attendance"
  | "records"
  | "finance"
  | "insurance"
  | "tests"
  | "prescriptions"
  | "chat"
  | "reports"
  | "settings"
  | "permissions";

type AppView = MenuPermission | ClinicView;

type ClinicDashboardSummary = {
  appointmentsToday: number;
  confirmedAppointments: number;
  revenueMonth: number;
  noShowRate: number;
  activePatients: number;
  activeProfessionals: number;
};

type ClinicPatient = {
  id: string;
  tenantId: string;
  fullName: string;
  birthDate: string;
  gender: string;
  phone: string;
  email: string;
  insurance: string;
  notes: string;
};

type ClinicProfessional = {
  id: string;
  tenantId: string;
  fullName: string;
  specialty: string;
  licenseNumber: string;
  appointmentDurationMinutes: number;
  active: boolean;
};

type ClinicAppointment = {
  id: string;
  tenantId: string;
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

type ClinicPatientSummary = {
  patientId: string;
  clinicalSummary: string;
  attentionPoints: string;
  suggestedNextSteps: string;
};

type PatientFormState = {
  fullName: string;
  birthDate: string;
  gender: string;
  phone: string;
  email: string;
  document: string;
  insurance: string;
  notes: string;
};

type ProfessionalFormState = {
  fullName: string;
  specialty: string;
  licenseNumber: string;
  appointmentDurationMinutes: string;
};

type AppointmentFormState = {
  patientId: string;
  professionalId: string;
  clinicUnitName: string;
  startAtUtc: string;
  notes: string;
};

const demoUsers: SessionUser[] = [
  {
    id: "platform-admin",
    name: "Maurício Henrique",
    email: "admin@clinicflow.ai",
    role: "platform_admin",
    password: "clinicflow123"
  },
  {
    id: "clinic-admin-rita",
    name: "Rita Sousa",
    email: "rita@clinivida.pt",
    role: "clinic_admin",
    clientId: "4abf12d8-5e43-4c6b-9f10-eaf4b5870001",
    password: "clinica123"
  },
  {
    id: "staff-luisa",
    name: "Luisa Ramos",
    email: "recepcao@clinivida.pt",
    role: "staff",
    clientId: "4abf12d8-5e43-4c6b-9f10-eaf4b5870001",
    password: "equipa123"
  }
];

const rolePermissions: Record<AppRole, MenuPermission[]> = {
  platform_admin: ["dashboard", "clients", "billing", "renewals", "suspensions", "messages", "notes", "alerts", "plans", "reports", "audit", "settings", "clinic_access"],
  clinic_admin: ["dashboard", "clients", "billing", "messages", "notes", "settings", "clinic_access"],
  staff: ["dashboard", "clients", "messages"]
};

const DEMO_TENANT_ID = "a84e7a32-6d4c-4a13-8b25-3f4d580cc111";

const initialPatientForm: PatientFormState = {
  fullName: "",
  birthDate: "",
  gender: "Female",
  phone: "",
  email: "",
  document: "",
  insurance: "",
  notes: ""
};

const initialProfessionalForm: ProfessionalFormState = {
  fullName: "",
  specialty: "",
  licenseNumber: "",
  appointmentDurationMinutes: "30"
};

const initialAppointmentForm: AppointmentFormState = {
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
    throw new Error(message || `Request failed with status ${response.status}`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

async function fetchClinicJson<T>(path: string, options?: RequestInit): Promise<T> {
  const headers = new Headers(options?.headers);
  headers.set("X-Tenant-Id", DEMO_TENANT_ID);

  return fetchJson<T>(path, {
    ...options,
    headers
  });
}

function formatCurrency(value: number, locale: string) {
  return new Intl.NumberFormat(locale, {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0
  }).format(value);
}

function formatDate(date: string, locale: string) {
  return new Intl.DateTimeFormat(locale, {
    day: "2-digit",
    month: "short",
    year: "numeric"
  }).format(new Date(date));
}

function formatDateTime(date: string, locale: string) {
  return new Intl.DateTimeFormat(locale, {
    day: "2-digit",
    month: "short",
    hour: "2-digit",
    minute: "2-digit"
  }).format(new Date(date));
}

function formatTime(date: string, locale: string) {
  return new Intl.DateTimeFormat(locale, {
    hour: "2-digit",
    minute: "2-digit"
  }).format(new Date(date));
}

function appointmentStatusLabel(status: number) {
  switch (status) {
    case 1:
      return "Agendada";
    case 2:
      return "Confirmada";
    case 3:
      return "Em atendimento";
    case 4:
      return "Concluída";
    case 5:
      return "Cancelada";
    case 6:
      return "Faltou";
    default:
      return "Sem status";
  }
}

function appointmentTone(status: number) {
  switch (status) {
    case 2:
    case 4:
      return "green";
    case 3:
      return "blue";
    case 5:
    case 6:
      return "pink";
    default:
      return "yellow";
  }
}

function normalizeBillingStatus(status: string) {
  const normalizedStatus = status.trim().toLowerCase();

  if (normalizedStatus.includes("paid") || normalizedStatus.includes("pago")) return "paid";
  if (normalizedStatus.includes("overdue") || normalizedStatus.includes("atras")) return "overdue";
  if (normalizedStatus.includes("suspended") || normalizedStatus.includes("suspenso") || normalizedStatus.includes("suspendido")) return "suspended";
  if (normalizedStatus.includes("trial") || normalizedStatus.includes("teste") || normalizedStatus.includes("prueba")) return "trialEnding";
  return "unknown";
}

function statusTone(status: string) {
  const normalizedStatus = normalizeBillingStatus(status);

  if (normalizedStatus === "paid") return "green";
  if (normalizedStatus === "overdue") return "yellow";
  if (normalizedStatus === "suspended") return "pink";
  return "blue";
}

function buildDefaultMessage(language: string) {
  if (language === "en") {
    return {
      subject: "Payment reminder",
      body: "Hello, your ClinicFlow subscription is close to interruption due to unpaid invoices. If you need help, reply to this message."
    };
  }

  if (language === "es") {
    return {
      subject: "Recordatorio de pago",
      body: "Hola, su suscripción de ClinicFlow está cerca de ser interrumpida por falta de pago. Si necesita ayuda, responda a este mensaje."
    };
  }

  return {
    subject: "Lembrete de pagamento",
    body: "Olá, a sua assinatura do ClinicFlow está perto de ser interrompida por falta de pagamento. Se precisar de ajuda, responda a esta mensagem."
  };
}

function getInitialSession() {
  if (typeof window === "undefined") {
    return null;
  }

  const rawSession = window.localStorage.getItem(SESSION_STORAGE_KEY);

  if (!rawSession) {
    return null;
  }

  try {
    const parsed = JSON.parse(rawSession) as Omit<SessionUser, "password">;
    return parsed;
  } catch {
    return null;
  }
}

function getLocalizedBillingStatus(status: string, dictionary: ReturnType<typeof useLanguage>["t"]) {
  return dictionary.billingStatuses[normalizeBillingStatus(status)];
}

function cutoffLabel(daysUntilCutoff: number, dictionary: ReturnType<typeof useLanguage>["t"]) {
  if (daysUntilCutoff <= 0) return dictionary.cutoffReady;
  if (daysUntilCutoff === 1) return dictionary.cutoffOneDay;
  return dictionary.cutoffManyDays(daysUntilCutoff);
}

function translateChannel(channel: string, dictionary: ReturnType<typeof useLanguage>["t"]) {
  return channel.toLowerCase().includes("whatsapp") ? dictionary.channels.whatsapp : dictionary.channels.email;
}

function translateRole(role: string, dictionary: ReturnType<typeof useLanguage>["t"]) {
  if (role === "ClinicAdmin") return dictionary.roles.clinicAdmin;
  if (role === "Staff") return dictionary.roles.staff;
  return role;
}

function translateAppRole(role: AppRole, dictionary: ReturnType<typeof useLanguage>["t"]) {
  if (role === "platform_admin") return dictionary.rolePlatformAdmin;
  if (role === "clinic_admin") return dictionary.roleClinicAdmin;
  return dictionary.roleStaff;
}

function translateLastPaymentLabel(label: string, dictionary: ReturnType<typeof useLanguage>["t"]) {
  const paidMatch = label.match(/^Paid on (.+)$/i);
  if (paidMatch) return dictionary.paymentLabels.paidOn(paidMatch[1]);

  const overdueMatch = label.match(/^Invoice overdue by (\d+) days?$/i);
  if (overdueMatch) return dictionary.paymentLabels.overdueByDays(Number(overdueMatch[1]));

  const trialMatch = label.match(/^Trial ends in (\d+) days?$/i);
  if (trialMatch) return dictionary.paymentLabels.trialEndsInDays(Number(trialMatch[1]));

  const suspendedMatch = label.match(/^Service suspended on (.+)$/i);
  if (suspendedMatch) return dictionary.paymentLabels.suspendedOn(suspendedMatch[1]);

  if (label === "1 month courtesy granted by admin") {
    return dictionary.successGiftMonth;
  }

  return label;
}

function userInitials(name: string) {
  return name
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("");
}

function permissionPills(member: PlatformAccessMember, dictionary: ReturnType<typeof useLanguage>["t"]) {
  return [
    member.canViewDashboard ? dictionary.permissionsDashboard : null,
    member.canViewBilling ? dictionary.permissionsBilling : null,
    member.canManagePatients ? dictionary.permissionsPatients : null,
    member.canManageSchedule ? dictionary.permissionsSchedule : null,
    member.canManageSettings ? dictionary.permissionsSettings : null
  ].filter(Boolean) as string[];
}

function findClinicAccessProfile(members: PlatformAccessMember[], email: string) {
  return members.find((member) => member.email.toLowerCase() === email.trim().toLowerCase()) ?? null;
}

function LoginScreen({
  onLogin
}: {
  onLogin: (user: Omit<SessionUser, "password">) => void;
}) {
  const { language, setLanguage, t, availableLanguages } = useLanguage();
  const [showRecovery, setShowRecovery] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [recoveryEmail, setRecoveryEmail] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  function handleLogin(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(null);

    const matchedUser = demoUsers.find((user) => user.email.toLowerCase() === email.trim().toLowerCase() && user.password === password);

    if (!matchedUser) {
      setError(t.loginInvalidCredentials);
      return;
    }

    const { password: _, ...safeUser } = matchedUser;
    window.localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(safeUser));
    onLogin(safeUser);
  }

  function handleRecovery(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setError(null);
    setSuccess(t.loginRecoverySuccess);
  }

  return (
    <main className="auth-shell">
      <div className="auth-backdrop" />
      <section className="auth-layout">
        <article className="auth-brand-card">
          <p className="eyebrow">{t.loginEyebrow}</p>
          <h1>{t.loginTitle}</h1>
          <p>{t.loginDescription}</p>

          <div className="auth-demo-list">
            <p className="auth-section-title">{t.loginDemoTitle}</p>
            {demoUsers.map((user) => (
              <button
                key={user.id}
                type="button"
                className="demo-account"
                onClick={() => {
                  setEmail(user.email);
                  setPassword(user.password);
                  setShowRecovery(false);
                }}
              >
                <div className="demo-avatar">{userInitials(user.name)}</div>
                <div>
                  <strong>{user.name}</strong>
                  <span>{user.email}</span>
                  <span>{translateAppRole(user.role, t)}</span>
                </div>
              </button>
            ))}
          </div>
        </article>

        <article className="auth-card">
          <div className="auth-card-head">
            <div className="sidebar-logo">CF</div>
            <label className="language-field light">
              <span>{t.languageFieldLabel}</span>
              <select value={language} onChange={(event) => setLanguage(event.target.value as typeof language)}>
                {availableLanguages.map((option) => (
                  <option key={option.code} value={option.code}>
                    {option.label}
                  </option>
                ))}
              </select>
            </label>
          </div>

          {!showRecovery ? (
            <form className="stack-form" onSubmit={handleLogin}>
              <label className="field-label">
                <span>{t.loginEmailLabel}</span>
                <input value={email} onChange={(event) => setEmail(event.target.value)} placeholder="admin@clinicflow.ai" />
              </label>

              <label className="field-label">
                <span>{t.loginPasswordLabel}</span>
                <input
                  type="password"
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  placeholder={t.loginPasswordPlaceholder}
                />
              </label>

              {error ? <p className="status-text error">{error}</p> : null}
              {success ? <p className="status-text success">{success}</p> : null}

              <button type="submit">{t.loginButton}</button>
              <button type="button" className="ghost-action" onClick={() => setShowRecovery(true)}>
                {t.loginForgotPassword}
              </button>
            </form>
          ) : (
            <form className="stack-form" onSubmit={handleRecovery}>
              <div>
                <p className="panel-kicker auth-kicker">{t.loginRecoveryTitle}</p>
                <p className="auth-recovery-copy">{t.loginRecoveryDescription}</p>
              </div>

              <label className="field-label">
                <span>{t.loginEmailLabel}</span>
                <input value={recoveryEmail} onChange={(event) => setRecoveryEmail(event.target.value)} placeholder="nome@clinica.pt" />
              </label>

              {success ? <p className="status-text success">{success}</p> : null}

              <button type="submit">{t.loginRecoveryButton}</button>
              <button type="button" className="ghost-action" onClick={() => setShowRecovery(false)}>
                {t.loginBackToAccess}
              </button>
            </form>
          )}
        </article>
      </section>
    </main>
  );
}

export function App() {
  const { language, setLanguage, t, availableLanguages } = useLanguage();
  const [currentUser, setCurrentUser] = useState<Omit<SessionUser, "password"> | null>(getInitialSession);
  const [activeMenu, setActiveMenu] = useState<AppView>("clients");
  const [dashboard, setDashboard] = useState<PlatformDashboard | null>(null);
  const [clients, setClients] = useState<PlatformClient[]>([]);
  const [messages, setMessages] = useState<PlatformMessage[]>([]);
  const [accessMembers, setAccessMembers] = useState<PlatformAccessMember[]>([]);
  const [clinicSummary, setClinicSummary] = useState<ClinicDashboardSummary | null>(null);
  const [clinicPatients, setClinicPatients] = useState<ClinicPatient[]>([]);
  const [clinicProfessionals, setClinicProfessionals] = useState<ClinicProfessional[]>([]);
  const [clinicAppointments, setClinicAppointments] = useState<ClinicAppointment[]>([]);
  const [selectedClinicPatientId, setSelectedClinicPatientId] = useState<string>("");
  const [clinicPatientSummary, setClinicPatientSummary] = useState<ClinicPatientSummary | null>(null);
  const [patientForm, setPatientForm] = useState<PatientFormState>(initialPatientForm);
  const [professionalForm, setProfessionalForm] = useState<ProfessionalFormState>(initialProfessionalForm);
  const [appointmentForm, setAppointmentForm] = useState<AppointmentFormState>(initialAppointmentForm);
  const [selectedClientId, setSelectedClientId] = useState<string>("");
  const [draftNote, setDraftNote] = useState("");
  const defaultMessage = buildDefaultMessage(language);
  const [messageForm, setMessageForm] = useState<MessageForm>({
    clientId: "",
    channel: "Email",
    subject: defaultMessage.subject,
    body: defaultMessage.body
  });
  const [accessForm, setAccessForm] = useState<AccessMemberForm>({
    fullName: "",
    email: "",
    role: "Staff",
    canViewDashboard: true,
    canViewBilling: false,
    canManagePatients: true,
    canManageSchedule: true,
    canManageSettings: false
  });
  const [isLoading, setIsLoading] = useState(true);
  const [isClinicLoading, setIsClinicLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const menuSections = [
    {
      title: t.sidebarSections[0].title,
      items: [
        { label: t.sidebarSections[0].items[0], permission: "dashboard" as const },
        { label: t.sidebarSections[0].items[1], permission: "clients" as const },
        { label: t.sidebarSections[0].items[2], permission: "billing" as const }
      ]
    },
    {
      title: t.sidebarSections[1].title,
      items: [
        { label: t.sidebarSections[1].items[0], permission: "clients" as const },
        { label: t.sidebarSections[1].items[1], permission: "billing" as const },
        { label: t.sidebarSections[1].items[2], permission: "renewals" as const },
        { label: t.sidebarSections[1].items[3], permission: "suspensions" as const }
      ]
    },
    {
      title: t.sidebarSections[2].title,
      items: [
        { label: t.sidebarSections[2].items[0], permission: "messages" as const },
        { label: t.sidebarSections[2].items[1], permission: "notes" as const },
        { label: t.sidebarSections[2].items[2], permission: "alerts" as const }
      ]
    },
    {
      title: t.sidebarSections[3].title,
      items: [
        { label: t.sidebarSections[3].items[0], permission: "plans" as const },
        { label: t.sidebarSections[3].items[1], permission: "reports" as const },
        { label: t.sidebarSections[3].items[2], permission: "audit" as const },
        { label: t.sidebarSections[3].items[3], permission: "settings" as const }
      ]
    }
  ];

  const allowedPermissions = currentUser ? rolePermissions[currentUser.role] : [];
  const visibleClients = useMemo(() => {
    if (!currentUser) return [];
    if (currentUser.role === "platform_admin") return clients;
    return clients.filter((client) => client.id === currentUser.clientId);
  }, [clients, currentUser]);

  const selectedClient = useMemo(
    () => visibleClients.find((client) => client.id === selectedClientId) ?? visibleClients[0] ?? null,
    [visibleClients, selectedClientId]
  );

  const canManageClinicAccess = currentUser
    ? currentUser.role === "platform_admin" || (currentUser.role === "clinic_admin" && currentUser.clientId === selectedClient?.id)
    : false;

  useEffect(() => {
    if (!currentUser) {
      return;
    }

    void refreshData(currentUser);
    if (currentUser.role !== "platform_admin") {
      void refreshClinicData();
    }
  }, [currentUser]);

  useEffect(() => {
    if (!currentUser) {
      return;
    }

    setActiveMenu(currentUser.role === "platform_admin" ? "clients" : "dashboard");
  }, [currentUser]);

  useEffect(() => {
    if (!selectedClient && visibleClients.length > 0) {
      setSelectedClientId(visibleClients[0].id);
      return;
    }

    if (selectedClient) {
      setDraftNote(selectedClient.notes);
      setMessageForm((current) => ({
        ...current,
        clientId: selectedClient.id
      }));
    }
  }, [visibleClients, selectedClient]);

  useEffect(() => {
    if (!selectedClinicPatientId && clinicPatients[0]) {
      setSelectedClinicPatientId(clinicPatients[0].id);
    }
  }, [clinicPatients, selectedClinicPatientId]);

  useEffect(() => {
    if (!selectedClient) {
      setAccessMembers([]);
      return;
    }

    void loadAccessMembers(selectedClient.id);
  }, [selectedClient?.id]);

  useEffect(() => {
    setMessageForm((current) => ({
      ...current,
      subject: defaultMessage.subject,
      body: defaultMessage.body
    }));
  }, [language]);

  async function refreshData(user = currentUser) {
    if (!user) return;

    setError(null);
    setIsLoading(true);

    try {
      const [dashboardData, clientData, messageData] = await Promise.all([
        fetchJson<PlatformDashboard>("/api/platform/dashboard"),
        fetchJson<PlatformClient[]>("/api/platform/clients"),
        fetchJson<PlatformMessage[]>("/api/platform/messages")
      ]);

      setDashboard(dashboardData);
      setClients(clientData);
      setMessages(messageData);

      const firstVisibleClient = user.role === "platform_admin"
        ? clientData[0]
        : clientData.find((client) => client.id === user.clientId);

      if (!selectedClientId && firstVisibleClient) {
        setSelectedClientId(firstVisibleClient.id);
      }
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : t.errorLoad);
    } finally {
      setIsLoading(false);
    }
  }

  async function refreshClinicData() {
    setIsClinicLoading(true);

    try {
      const [summaryData, patientData, professionalData, appointmentData] = await Promise.all([
        fetchClinicJson<ClinicDashboardSummary>("/api/dashboard/summary"),
        fetchClinicJson<ClinicPatient[]>("/api/patients"),
        fetchClinicJson<ClinicProfessional[]>("/api/professionals"),
        fetchClinicJson<ClinicAppointment[]>("/api/appointments")
      ]);

      setClinicSummary(summaryData);
      setClinicPatients(patientData);
      setClinicProfessionals(professionalData);
      setClinicAppointments(appointmentData);

      setAppointmentForm((current) => ({
        ...current,
        patientId: current.patientId || patientData[0]?.id || "",
        professionalId: current.professionalId || professionalData[0]?.id || ""
      }));
    } catch (loadError) {
      setError(loadError instanceof Error ? loadError.message : "Não foi possível carregar os dados da clínica.");
    } finally {
      setIsClinicLoading(false);
    }
  }

  async function loadAccessMembers(clientId: string) {
    try {
      const memberData = await fetchJson<PlatformAccessMember[]>(`/api/platform/clients/${clientId}/access-members`);
      setAccessMembers(memberData);
    } catch {
      setAccessMembers([]);
    }
  }

  async function handleGiftMonth(clientId: string) {
    setSuccess(null);
    setError(null);

    try {
      await fetchJson(`/api/platform/clients/${clientId}/gift-month`, { method: "POST" });
      setSuccess(t.successGiftMonth);
      await refreshData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : t.errorGiftMonth);
    }
  }

  async function handleSuspend(clientId: string) {
    setSuccess(null);
    setError(null);

    try {
      await fetchJson(`/api/platform/clients/${clientId}/suspend`, { method: "POST" });
      setSuccess(t.successSuspend);
      await refreshData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : t.errorSuspend);
    }
  }

  async function handleDelete(clientId: string) {
    setSuccess(null);
    setError(null);

    try {
      await fetchJson(`/api/platform/clients/${clientId}`, { method: "DELETE" });
      setSuccess(t.successDelete);
      setSelectedClientId("");
      await refreshData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : t.errorDelete);
    }
  }

  async function handleSaveNote(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!selectedClient) return;

    setSuccess(null);
    setError(null);

    try {
      await fetchJson(`/api/platform/clients/${selectedClient.id}/note`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ notes: draftNote })
      });
      setSuccess(t.successNote);
      await refreshData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : t.errorNote);
    }
  }

  async function handleSendMessage(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!messageForm.clientId) return;

    setSuccess(null);
    setError(null);

    try {
      await fetchJson("/api/platform/messages", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(messageForm)
      });
      setSuccess(t.successMessage);
      await refreshData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : t.errorMessage);
    }
  }

  async function handleCreateAccessMember(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!selectedClient) return;

    setSuccess(null);
    setError(null);

    try {
      await fetchJson(`/api/platform/clients/${selectedClient.id}/access-members`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(accessForm)
      });

      setSuccess(t.successAccessMember);
      setAccessForm({
        fullName: "",
        email: "",
        role: "Staff",
        canViewDashboard: true,
        canViewBilling: false,
        canManagePatients: true,
        canManageSchedule: true,
        canManageSettings: false
      });
      await loadAccessMembers(selectedClient.id);
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : t.errorAccessMember);
    }
  }

  async function handleCreateClinicPatient(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSuccess(null);
    setError(null);

    try {
      await fetchClinicJson("/api/patients", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          fullName: patientForm.fullName,
          birthDate: patientForm.birthDate,
          gender: patientForm.gender,
          phone: patientForm.phone,
          email: patientForm.email,
          document: patientForm.document,
          insurance: patientForm.insurance,
          notes: patientForm.notes
        })
      });

      setPatientForm(initialPatientForm);
      setSuccess("Paciente criado com sucesso.");
      await refreshClinicData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : "Não foi possível criar o paciente.");
    }
  }

  async function handleCreateClinicProfessional(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSuccess(null);
    setError(null);

    try {
      await fetchClinicJson("/api/professionals", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          fullName: professionalForm.fullName,
          specialty: professionalForm.specialty,
          licenseNumber: professionalForm.licenseNumber,
          appointmentDurationMinutes: Number(professionalForm.appointmentDurationMinutes)
        })
      });

      setProfessionalForm(initialProfessionalForm);
      setSuccess("Profissional criado com sucesso.");
      await refreshClinicData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : "Não foi possível criar o profissional.");
    }
  }

  async function handleCreateClinicAppointment(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSuccess(null);
    setError(null);

    try {
      await fetchClinicJson("/api/appointments", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          patientId: appointmentForm.patientId,
          professionalId: appointmentForm.professionalId,
          clinicUnitName: appointmentForm.clinicUnitName,
          startAtUtc: new Date(appointmentForm.startAtUtc).toISOString(),
          notes: appointmentForm.notes
        })
      });

      setAppointmentForm((current) => ({
        ...initialAppointmentForm,
        patientId: clinicPatients[0]?.id || current.patientId,
        professionalId: clinicProfessionals[0]?.id || current.professionalId
      }));
      setSuccess("Agendamento criado com sucesso.");
      await refreshClinicData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : "Não foi possível criar o agendamento.");
    }
  }

  async function handleUpdateClinicAppointmentStatus(appointmentId: string, status: number) {
    setSuccess(null);
    setError(null);

    try {
      await fetchClinicJson(`/api/appointments/${appointmentId}/status`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          status,
          cancellationReason: status === 5 ? "Cancelado pela clínica" : null
        })
      });

      setSuccess("Status atualizado.");
      await refreshClinicData();
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : "Não foi possível atualizar o status.");
    }
  }

  async function handleGenerateClinicPatientSummary(patientId: string) {
    setSuccess(null);
    setError(null);

    try {
      const summary = await fetchClinicJson<ClinicPatientSummary>(`/api/ai/patient-summary/${patientId}`, {
        method: "POST"
      });
      setClinicPatientSummary(summary);
      setSuccess("Resumo de IA gerado.");
    } catch (actionError) {
      setError(actionError instanceof Error ? actionError.message : "Não foi possível gerar o resumo.");
    }
  }

  function handleLogout() {
    window.localStorage.removeItem(SESSION_STORAGE_KEY);
    setCurrentUser(null);
    setDashboard(null);
    setClients([]);
    setMessages([]);
    setAccessMembers([]);
    setSelectedClientId("");
    setError(null);
    setSuccess(null);
  }

  if (!currentUser) {
    return <LoginScreen onLogin={setCurrentUser} />;
  }

  const clinicAccessProfile = currentUser.role === "platform_admin" ? null : findClinicAccessProfile(accessMembers, currentUser.email);
  const selectedClinicPatient = clinicPatients.find((patient) => patient.id === selectedClinicPatientId) ?? clinicPatients[0] ?? null;

  if (currentUser.role !== "platform_admin") {
    const clinicMenu = [
      { key: "dashboard", label: "Home", enabled: true },
      { key: "agenda", label: "Agenda", enabled: clinicAccessProfile?.canManageSchedule ?? false },
      { key: "patients", label: "Pacientes", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { key: "doctors", label: "Médicos", enabled: clinicAccessProfile?.canManageSchedule ?? false },
      { key: "attendance", label: "Atendimentos", enabled: clinicAccessProfile?.canViewDashboard ?? false },
      { key: "records", label: "Prontuários", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { key: "finance", label: "Financeiro", enabled: clinicAccessProfile?.canViewBilling ?? false },
      { key: "insurance", label: "Convênios", enabled: clinicAccessProfile?.canViewBilling ?? false },
      { key: "tests", label: "Exames", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { key: "prescriptions", label: "Prescrições", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { key: "chat", label: "Chat / WhatsApp", enabled: true },
      { key: "reports", label: "Relatórios", enabled: clinicAccessProfile?.canViewDashboard ?? false },
      { key: "settings", label: "Configurações", enabled: clinicAccessProfile?.canManageSettings ?? false },
      { key: "permissions", label: "Usuários e permissões", enabled: currentUser.role === "clinic_admin" }
    ];

    const homeModules = [
      { title: "Agenda organizada", description: "Veja horários, confirmações e encaixes sem expor dados clínicos na abertura." },
      { title: "Pacientes e CRM", description: "Cadastros, observações e histórico básico reunidos em um espaço único." },
      { title: "Atendimento clínico", description: "Prontuários, retornos e fluxo de consulta com acesso conforme o perfil." },
      { title: "Financeiro e convênios", description: "Cobrança, pagamentos e pendências visíveis apenas para quem tem permissão." }
    ];

    const scheduleItems = [
      { time: "09:00", patient: "Ana Souza", doctor: "Dr. Carlos", type: "Consulta", status: "Confirmado", tone: "green" },
      { time: "09:30", patient: "João Lima", doctor: "Dra. Fernanda", type: "Retorno", status: "Aguardando", tone: "yellow" },
      { time: "10:00", patient: "Pedro Alves", doctor: "Dr. Ricardo", type: "Exame", status: "Em atendimento", tone: "blue" },
      { time: "10:30", patient: "Maria Costa", doctor: "Dra. Paula", type: "Consulta", status: "Cancelado", tone: "pink" },
      { time: "11:00", patient: "Lucas Mendes", doctor: "Dr. André", type: "Check-up", status: "Confirmado", tone: "green" }
    ];

    const nextAppointments = [
      { patient: "Mariana Lopes", doctor: "Dr. Felipe", time: "11:30", avatar: "ML" },
      { patient: "Carlos Pereira", doctor: "Dra. Sofia", time: "12:00", avatar: "CP" }
    ];

    const alerts = [
      { title: "3 pacientes faltosos", tone: "pink" },
      { title: "Convênio XYZ vencido", tone: "yellow" },
      { title: "8 retornos pendentes", tone: "blue" },
      { title: "5 cobranças em aberto", tone: "green" }
    ];

    const quickActions = [
      { label: "Novo paciente", tone: "blue", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { label: "Novo agendamento", tone: "green", enabled: clinicAccessProfile?.canManageSchedule ?? false },
      { label: "Emitir receita", tone: "yellow", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { label: "Solicitar exame", tone: "pink", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { label: "Enviar mensagem", tone: "blue", enabled: true }
    ];

    const clinicStats = [
      { label: "Consultas hoje", value: "42", tone: "blue" },
      { label: "Pacientes aguardando", value: "8", tone: "green" },
      { label: "Cancelamentos", value: "5", tone: "pink" },
      { label: "Faturamento do mês", value: formatCurrency(selectedClient?.monthlyAmount ? selectedClient.monthlyAmount * 50 : 12450, t.locale), tone: "green" },
      { label: "Ocupação da agenda", value: "92%", tone: "green" },
      { label: "Novos pacientes", value: "16", tone: "green" },
      { label: "Convênios pendentes", value: "7", tone: "yellow" },
      { label: "Exames pendentes", value: "14", tone: "blue" }
    ];

    const clinicPageContent: Record<string, { kicker: string; title: string; description: string; highlights: string[]; columns: Array<{ title: string; items: string[] }> }> = {
      agenda: {
        kicker: "Agenda clínica",
        title: "Coordene horários, confirmações e encaixes",
        description: "Uma visão organizada dos horários do dia, dos próximos blocos disponíveis e das ações de receção que mais exigem atenção.",
        highlights: ["Agenda por profissional", "Bloqueios e encaixes", "Confirmações do dia"],
        columns: [
          { title: "Hoje", items: ["Consultas confirmadas e pendentes", "Encaixes sugeridos pela receção", "Blocos vazios para reposição"] },
          { title: "Acompanhamento", items: ["Remarcações recentes", "Alertas de atraso", "Fila de atendimento"] },
          { title: "Atalhos", items: ["Abrir calendário", "Criar agendamento", "Emitir lembrete"] }
        ]
      },
      patients: {
        kicker: "Pacientes",
        title: "Mantenha o cadastro e o relacionamento sob controle",
        description: "A área de pacientes concentra contactos, observações importantes, histórico básico e contexto útil para receção e atendimento.",
        highlights: ["Cadastro único", "Observações internas", "Histórico resumido"],
        columns: [
          { title: "Cadastro", items: ["Dados pessoais", "Contactos e convénios", "Sinalização de prioridades"] },
          { title: "Relacionamento", items: ["Últimos atendimentos", "Retornos recomendados", "Pendências de contacto"] },
          { title: "Ações", items: ["Novo paciente", "Atualizar dados", "Enviar mensagem"] }
        ]
      },
      doctors: {
        kicker: "Equipe clínica",
        title: "Organize médicos e profissionais por disponibilidade",
        description: "Veja a equipa da clínica, a especialidade de cada profissional e o impacto direto que isso tem na agenda e na operação.",
        highlights: ["Especialidades", "Disponibilidade semanal", "Capacidade de atendimento"],
        columns: [
          { title: "Profissionais", items: ["Lista da equipa ativa", "Carga horária por turno", "Cobertura por unidade"] },
          { title: "Coordenação", items: ["Bloqueios de agenda", "Férias e ausências", "Duração média por consulta"] },
          { title: "Ações", items: ["Adicionar profissional", "Editar agenda", "Rever capacidade"] }
        ]
      },
      attendance: {
        kicker: "Atendimentos",
        title: "Acompanhe a operação clínica em tempo real",
        description: "Entrada, chamada, atendimento e conclusão num fluxo claro para que a equipa saiba exatamente o que está a acontecer.",
        highlights: ["Fila do dia", "Consultas em andamento", "Concluídos e pendências"],
        columns: [
          { title: "Fila", items: ["Pacientes aguardando", "Ordem de chamada", "Tempo médio de espera"] },
          { title: "Execução", items: ["Em atendimento", "Atendimentos encerrados", "Pendências de registo"] },
          { title: "Ações", items: ["Abrir atendimento", "Atualizar status", "Encerrar consulta"] }
        ]
      },
      records: {
        kicker: "Prontuários",
        title: "Prontuário organizado e fácil de navegar",
        description: "Tenha um espaço dedicado para evolução clínica, resumo de IA, retorno sugerido e notas essenciais por atendimento.",
        highlights: ["Timeline clínica", "Resumo inteligente", "Acompanhamento contínuo"],
        columns: [
          { title: "Estrutura", items: ["SOAP e observações", "Histórico cronológico", "Resultados de exames"] },
          { title: "IA", items: ["Resumo automático", "Pontos de atenção", "Sugestão de retorno"] },
          { title: "Ações", items: ["Abrir prontuário", "Anexar documento", "Gerar resumo"] }
        ]
      },
      finance: {
        kicker: "Financeiro",
        title: "Veja receitas, pendências e repasses com clareza",
        description: "Um módulo financeiro limpo para cobranças, pagamentos, faturação do mês e visão rápida do que precisa de decisão.",
        highlights: ["Receita do período", "Contas em aberto", "Conferência de pagamentos"],
        columns: [
          { title: "Receita", items: ["Consultas faturadas", "Recebimentos por forma de pagamento", "Resumo por período"] },
          { title: "Pendências", items: ["Cobranças em aberto", "Convénios atrasados", "Receitas não conciliadas"] },
          { title: "Ações", items: ["Lançar pagamento", "Emitir recibo", "Exportar relatório"] }
        ]
      },
      insurance: {
        kicker: "Convénios",
        title: "Mantenha contratos, regras e pendências sob controlo",
        description: "Acompanhe convénios ativos, vencimentos próximos e impactos operacionais sem misturar isso com a receção do dia.",
        highlights: ["Planos ativos", "Vencimentos próximos", "Glosas e pendências"],
        columns: [
          { title: "Gestão", items: ["Convénios ativos", "Regras por operadora", "Status de documentação"] },
          { title: "Atenção", items: ["Pendências de autorização", "Cobranças glosadas", "Renovações em análise"] },
          { title: "Ações", items: ["Atualizar convénio", "Solicitar autorização", "Emitir contacto"] }
        ]
      },
      tests: {
        kicker: "Exames",
        title: "Controle pedidos, resultados e próximos passos",
        description: "Centralize exames pendentes, entregues e em análise para que a equipa encontre rapidamente o que precisa.",
        highlights: ["Pedidos em aberto", "Resultados recebidos", "Seguimento pendente"],
        columns: [
          { title: "Pedidos", items: ["Solicitações recentes", "Exames por especialidade", "Prioridades clínicas"] },
          { title: "Resultados", items: ["Laudos recebidos", "Pendências de validação", "Documentos anexados"] },
          { title: "Ações", items: ["Solicitar exame", "Anexar laudo", "Notificar paciente"] }
        ]
      },
      prescriptions: {
        kicker: "Prescrições",
        title: "Emissão organizada e acompanhamento do que foi prescrito",
        description: "Um ambiente seguro para acompanhar prescrições emitidas, pendências e próximas ações clínicas.",
        highlights: ["Receitas emitidas", "Renovações", "Histórico terapêutico"],
        columns: [
          { title: "Emissão", items: ["Receitas do dia", "Modelos padronizados", "Assinatura digital"] },
          { title: "Seguimento", items: ["Renovações pendentes", "Acompanhamento do tratamento", "Alertas de revisão"] },
          { title: "Ações", items: ["Emitir receita", "Reemitir prescrição", "Enviar ao paciente"] }
        ]
      },
      chat: {
        kicker: "Comunicação",
        title: "WhatsApp e mensagens num fluxo profissional",
        description: "Mensagens de confirmação, follow-up e contacto com pacientes e equipa num espaço de comunicação controlado.",
        highlights: ["Lembretes automáticos", "Mensagens manuais", "Histórico recente"],
        columns: [
          { title: "Pacientes", items: ["Confirmação de consulta", "Pós-consulta", "Retorno pendente"] },
          { title: "Equipe", items: ["Avisos internos", "Mudanças de agenda", "Orientações rápidas"] },
          { title: "Ações", items: ["Enviar mensagem", "Ver histórico", "Criar template"] }
        ]
      },
      reports: {
        kicker: "Relatórios",
        title: "Transforme operação em leitura executiva",
        description: "Agrupe métricas operacionais, financeiras e clínicas em relatórios fáceis de interpretar e apresentar.",
        highlights: ["Indicadores chave", "Ocupação e faltas", "Receita e produtividade"],
        columns: [
          { title: "Operação", items: ["Taxa de ocupação", "No-shows", "Tempo médio de espera"] },
          { title: "Financeiro", items: ["Receita por período", "Recebimentos por origem", "Pendências"] },
          { title: "Ações", items: ["Gerar relatório", "Comparar períodos", "Exportar PDF"] }
        ]
      },
      settings: {
        kicker: "Configurações",
        title: "Ajuste o sistema conforme a rotina da clínica",
        description: "Configurações gerais, regras operacionais, templates e parâmetros de funcionamento reunidos num espaço controlado.",
        highlights: ["Preferências do sistema", "Templates de comunicação", "Parâmetros operacionais"],
        columns: [
          { title: "Geral", items: ["Dados da clínica", "Unidades e contactos", "Identidade visual"] },
          { title: "Operação", items: ["Duração padrão", "Janelas de encaixe", "Políticas de cancelamento"] },
          { title: "Ações", items: ["Editar preferências", "Atualizar templates", "Rever integrações"] }
        ]
      },
      permissions: {
        kicker: "Usuários e permissões",
        title: "Defina claramente quem pode ver e alterar cada área",
        description: "Um módulo interno de acesso para autorizar colaboradores, limitar áreas sensíveis e manter a segurança da clínica.",
        highlights: ["Perfis ativos", "Permissões por função", "Histórico de acesso"],
        columns: [
          { title: "Perfis", items: ["Administrador da clínica", "Receção", "Médicos e equipa"] },
          { title: "Controlo", items: ["Permissões por módulo", "Acesso a dados sensíveis", "Ativação e bloqueio"] },
          { title: "Ações", items: ["Adicionar utilizador", "Editar permissões", "Rever auditoria"] }
        ]
      }
    };

    const currentClinicPage = clinicPageContent[activeMenu as string] ?? clinicPageContent.agenda;

    return (
      <main className="shell">
        <section className="app-frame clinic-frame">
          <aside className="sidebar clinic-sidebar">
            <div className="sidebar-brand">
              <div className="sidebar-logo">CF</div>
              <div>
                <p>{selectedClient?.clinicName ?? "ClinicFlow"}</p>
                <span>Painel de gestão clínica</span>
              </div>
            </div>

            <div className="sidebar-stack clinic-nav">
              {clinicMenu.map((item) => (
                <button
                  key={item.label}
                  type="button"
                    className={activeMenu === item.key ? "sidebar-item active" : item.enabled ? "sidebar-item" : "sidebar-item locked"}
                    disabled={!item.enabled}
                    title={item.enabled ? item.label : t.menuLockedLabel}
                    onClick={() => item.enabled && setActiveMenu(item.key as MenuPermission)}
                  >
                    <span>{item.label}</span>
                    {!item.enabled ? <small>{t.menuLockedLabel}</small> : null}
                  </button>
              ))}
            </div>

            <div className="sidebar-foot">
              <span>{currentUser.role === "clinic_admin" ? t.roleClinicAdmin : t.roleStaff}</span>
              <strong>{selectedClient?.clientCode ?? "Sem cliente"}</strong>
            </div>
          </aside>

          <section className="page clinic-page">
            <div className="page-topbar">
              <div className="topbar-copy">
                <p className="eyebrow">Operação clínica</p>
                <strong>{selectedClient?.clinicName ?? "Clínica ativa"}</strong>
              </div>
              <div className="session-card">
                <div className="session-avatar">{userInitials(currentUser.name)}</div>
                <div className="session-meta">
                  <strong>{currentUser.name}</strong>
                  <span>{currentUser.email}</span>
                  <span>{translateAppRole(currentUser.role, t)}</span>
                </div>
                <button type="button" className="ghost-action small" onClick={handleLogout}>
                  {t.topbarLogout}
                </button>
              </div>
            </div>

            {activeMenu === "dashboard" ? (
              <section className="clinic-home">
                <article className="clinic-home-hero">
                  <p className="eyebrow">Bem-vindo</p>
                  <h1>{selectedClient?.clinicName ?? "Sua clínica"}</h1>
                  <p>
                    Uma entrada limpa para a operação do dia, com acesso controlado por perfil e sem expor informações sensíveis logo ao abrir o sistema.
                  </p>
                  <div className="home-hero-tags">
                    <span>Ambiente seguro</span>
                    <span>Acesso por perfil</span>
                    <span>Operação organizada</span>
                  </div>
                </article>

                <article className="clinic-home-profile">
                  <div className="home-profile-top">
                    <div className="session-avatar">{userInitials(currentUser.name)}</div>
                    <div className="session-meta">
                      <strong>{currentUser.name}</strong>
                      <span>{translateAppRole(currentUser.role, t)}</span>
                      <span>{currentUser.email}</span>
                    </div>
                  </div>
                  <div className="home-profile-banner">
                    <span>Experiência inicial discreta</span>
                    <strong>As áreas sensíveis aparecem apenas quando o utilizador entra no módulo adequado.</strong>
                  </div>
                  <div className="home-profile-grid">
                    <div>
                      <span>Código</span>
                      <strong>{selectedClient?.clientCode ?? "Sem código"}</strong>
                    </div>
                    <div>
                      <span>Responsável</span>
                      <strong>{selectedClient?.ownerName ?? currentUser.name}</strong>
                    </div>
                  </div>
                </article>

                <section className="clinic-home-modules">
                  {homeModules.map((module) => (
                    <article className="home-module-card" key={module.title}>
                      <p className="panel-kicker">Módulo</p>
                      <h2>{module.title}</h2>
                      <p>{module.description}</p>
                    </article>
                  ))}
                </section>

                <article className="clinic-home-actions">
                  <div className="panel-header compact">
                    <div>
                      <p className="panel-kicker">Acesso rápido</p>
                      <h2>Escolha por onde começar</h2>
                    </div>
                  </div>
                  <div className="home-action-grid">
                    {clinicMenu.filter((item) => item.enabled && item.key !== "dashboard").slice(0, 6).map((item) => (
                      <button key={item.key} type="button" className="home-action-button" onClick={() => setActiveMenu(item.key as MenuPermission)}>
                        {item.label}
                      </button>
                    ))}
                  </div>
                </article>
              </section>
            ) : (
              <>
                <section className="clinic-stat-grid">
                  {clinicStats.map((card) => (
                    <article className={`clinic-stat-card tone-${card.tone}`} key={card.label}>
                      <strong>{card.value}</strong>
                      <span>{card.label}</span>
                    </article>
                  ))}
                </section>

                <section className="clinic-module-page">
                  <article className="clinic-module-hero">
                    <p className="eyebrow">{currentClinicPage.kicker}</p>
                    <h1>{currentClinicPage.title}</h1>
                    <p>{currentClinicPage.description}</p>
                    <div className="home-hero-tags">
                      {currentClinicPage.highlights.map((highlight) => (
                        <span key={highlight}>{highlight}</span>
                      ))}
                    </div>
                  </article>

                  {activeMenu === "agenda" && (
                    <section className="clinic-module-grid">
                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Agenda</p>
                            <h2>Consultas marcadas</h2>
                          </div>
                        </div>
                        <div className="schedule-list">
                          {clinicAppointments.map((appointment) => (
                            <div className="schedule-row" key={appointment.id}>
                              <strong>{formatTime(appointment.startAtUtc, t.locale)}</strong>
                              <div>
                                <p>{appointment.patientName}</p>
                                <span>{appointment.professionalName}</span>
                              </div>
                              <div className="schedule-meta">
                                <span>{appointment.clinicUnitName}</span>
                                <span className={`inline-status ${appointmentTone(appointment.status)}`}>
                                  {appointmentStatusLabel(appointment.status)}
                                </span>
                              </div>
                            </div>
                          ))}
                        </div>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Novo agendamento</p>
                            <h2>Criar consulta</h2>
                          </div>
                        </div>
                        <form className="stack-form" onSubmit={handleCreateClinicAppointment}>
                          <select value={appointmentForm.patientId} onChange={(event) => setAppointmentForm((current) => ({ ...current, patientId: event.target.value }))}>
                            {clinicPatients.map((patient) => (
                              <option key={patient.id} value={patient.id}>{patient.fullName}</option>
                            ))}
                          </select>
                          <select value={appointmentForm.professionalId} onChange={(event) => setAppointmentForm((current) => ({ ...current, professionalId: event.target.value }))}>
                            {clinicProfessionals.map((professional) => (
                              <option key={professional.id} value={professional.id}>{professional.fullName}</option>
                            ))}
                          </select>
                          <input value={appointmentForm.clinicUnitName} onChange={(event) => setAppointmentForm((current) => ({ ...current, clinicUnitName: event.target.value }))} placeholder="Unidade" />
                          <input type="datetime-local" value={appointmentForm.startAtUtc} onChange={(event) => setAppointmentForm((current) => ({ ...current, startAtUtc: event.target.value }))} />
                          <textarea rows={4} value={appointmentForm.notes} onChange={(event) => setAppointmentForm((current) => ({ ...current, notes: event.target.value }))} placeholder="Observações da consulta" />
                          <button disabled={!appointmentForm.patientId || !appointmentForm.professionalId || !appointmentForm.startAtUtc}>Guardar agendamento</button>
                        </form>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Leitura rápida</p>
                            <h2>Resumo do dia</h2>
                          </div>
                        </div>
                        <div className="module-list">
                          <div className="module-list-item"><span className="alert-dot blue" /><strong>{clinicSummary?.appointmentsToday ?? 0} consultas previstas hoje</strong></div>
                          <div className="module-list-item"><span className="alert-dot green" /><strong>{clinicSummary?.confirmedAppointments ?? 0} confirmadas</strong></div>
                          <div className="module-list-item"><span className="alert-dot yellow" /><strong>{clinicAppointments.filter((item) => item.noShowRiskScore >= 60).length} com risco elevado de falta</strong></div>
                        </div>
                      </article>
                    </section>
                  )}

                  {activeMenu === "patients" && (
                    <section className="clinic-module-grid">
                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Pacientes</p>
                            <h2>Lista ativa</h2>
                          </div>
                        </div>
                        <div className="message-list">
                          {clinicPatients.map((patient) => (
                            <div key={patient.id} className={patient.id === selectedClinicPatient?.id ? "list-card active" : "list-card"}>
                              <div className="list-card-top">
                                <strong>{patient.fullName}</strong>
                                <span className="badge blue">{patient.insurance}</span>
                              </div>
                              <p>{patient.phone}</p>
                              <p>{patient.email}</p>
                              <div className="card-actions">
                                <button type="button" className="mini-soft blue-soft" onClick={() => setSelectedClinicPatientId(patient.id)}>Selecionar</button>
                                <button type="button" className="mini-soft green-soft" onClick={() => { setSelectedClinicPatientId(patient.id); setActiveMenu("records"); }}>Prontuário</button>
                                <button type="button" className="mini-soft yellow-soft" onClick={() => { setSelectedClinicPatientId(patient.id); void handleGenerateClinicPatientSummary(patient.id); }}>Resumo IA</button>
                              </div>
                            </div>
                          ))}
                        </div>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Novo paciente</p>
                            <h2>Criar cadastro</h2>
                          </div>
                        </div>
                        <form className="stack-form" onSubmit={handleCreateClinicPatient}>
                          <input value={patientForm.fullName} onChange={(event) => setPatientForm((current) => ({ ...current, fullName: event.target.value }))} placeholder="Nome completo" />
                          <input type="date" value={patientForm.birthDate} onChange={(event) => setPatientForm((current) => ({ ...current, birthDate: event.target.value }))} />
                          <input value={patientForm.gender} onChange={(event) => setPatientForm((current) => ({ ...current, gender: event.target.value }))} placeholder="Género" />
                          <input value={patientForm.phone} onChange={(event) => setPatientForm((current) => ({ ...current, phone: event.target.value }))} placeholder="Telefone" />
                          <input value={patientForm.email} onChange={(event) => setPatientForm((current) => ({ ...current, email: event.target.value }))} placeholder="Email" />
                          <input value={patientForm.document} onChange={(event) => setPatientForm((current) => ({ ...current, document: event.target.value }))} placeholder="Documento" />
                          <input value={patientForm.insurance} onChange={(event) => setPatientForm((current) => ({ ...current, insurance: event.target.value }))} placeholder="Convénio" />
                          <textarea rows={4} value={patientForm.notes} onChange={(event) => setPatientForm((current) => ({ ...current, notes: event.target.value }))} placeholder="Observações" />
                          <button disabled={!patientForm.fullName || !patientForm.birthDate}>Guardar paciente</button>
                        </form>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Perfil selecionado</p>
                            <h2>{selectedClinicPatient?.fullName ?? "Sem paciente"}</h2>
                          </div>
                        </div>
                        {selectedClinicPatient ? (
                          <div className="module-list">
                            <div className="module-list-item"><span className="alert-dot blue" /><strong>{selectedClinicPatient.phone}</strong></div>
                            <div className="module-list-item"><span className="alert-dot green" /><strong>{selectedClinicPatient.email}</strong></div>
                            <div className="module-list-item"><span className="alert-dot yellow" /><strong>{selectedClinicPatient.notes || "Sem observações registadas"}</strong></div>
                            <div className="card-actions">
                              <button type="button" className="mini-soft blue-soft" onClick={() => setActiveMenu("chat")}>Enviar mensagem</button>
                              <button type="button" className="mini-soft pink-soft" onClick={() => setPatientForm((current) => ({ ...current, phone: "", email: "" }))}>Limpar contacto</button>
                              <button type="button" className="mini-soft green-soft" onClick={() => setActiveMenu("agenda")}>Novo agendamento</button>
                            </div>
                          </div>
                        ) : null}
                      </article>
                    </section>
                  )}

                  {activeMenu === "doctors" && (
                    <section className="clinic-module-grid">
                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Profissionais</p>
                            <h2>Equipe clínica</h2>
                          </div>
                        </div>
                        <div className="module-list">
                          {clinicProfessionals.map((professional) => (
                            <div className="module-list-item" key={professional.id}>
                              <span className="alert-dot green" />
                              <strong>{professional.fullName} · {professional.specialty} · {professional.appointmentDurationMinutes} min</strong>
                            </div>
                          ))}
                          <div className="card-actions">
                            <button type="button" className="mini-soft blue-soft" onClick={() => setActiveMenu("agenda")}>Abrir agenda</button>
                            <button type="button" className="mini-soft yellow-soft" onClick={() => setProfessionalForm(initialProfessionalForm)}>Novo profissional</button>
                          </div>
                        </div>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Novo profissional</p>
                            <h2>Adicionar à equipe</h2>
                          </div>
                        </div>
                        <form className="stack-form" onSubmit={handleCreateClinicProfessional}>
                          <input value={professionalForm.fullName} onChange={(event) => setProfessionalForm((current) => ({ ...current, fullName: event.target.value }))} placeholder="Nome completo" />
                          <input value={professionalForm.specialty} onChange={(event) => setProfessionalForm((current) => ({ ...current, specialty: event.target.value }))} placeholder="Especialidade" />
                          <input value={professionalForm.licenseNumber} onChange={(event) => setProfessionalForm((current) => ({ ...current, licenseNumber: event.target.value }))} placeholder="CRM / registro" />
                          <input value={professionalForm.appointmentDurationMinutes} onChange={(event) => setProfessionalForm((current) => ({ ...current, appointmentDurationMinutes: event.target.value }))} placeholder="Duração padrão" />
                          <button disabled={!professionalForm.fullName || !professionalForm.specialty}>Guardar profissional</button>
                        </form>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Capacidade</p>
                            <h2>Visão rápida</h2>
                          </div>
                        </div>
                        <div className="module-list">
                          <div className="module-list-item"><span className="alert-dot blue" /><strong>{clinicProfessionals.length} profissionais ativos</strong></div>
                          <div className="module-list-item"><span className="alert-dot yellow" /><strong>{clinicProfessionals.reduce((sum, item) => sum + item.appointmentDurationMinutes, 0)} minutos de duração padrão somados</strong></div>
                        </div>
                      </article>
                    </section>
                  )}

                  {activeMenu === "attendance" && (
                    <section className="clinic-module-grid">
                      <article className="panel clinic-panel module-card full-module-span">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Fila clínica</p>
                            <h2>Atendimentos e status</h2>
                          </div>
                        </div>
                        <div className="schedule-list">
                          {clinicAppointments.map((appointment) => (
                            <div className="schedule-row extended" key={appointment.id}>
                              <strong>{formatTime(appointment.startAtUtc, t.locale)}</strong>
                              <div>
                                <p>{appointment.patientName}</p>
                                <span>{appointment.professionalName}</span>
                              </div>
                              <div className="schedule-meta">
                                <span className={`inline-status ${appointmentTone(appointment.status)}`}>{appointmentStatusLabel(appointment.status)}</span>
                              </div>
                              <div className="row-actions">
                                <button type="button" className="ghost-action small" onClick={() => void handleUpdateClinicAppointmentStatus(appointment.id, 2)}>Confirmar</button>
                                <button type="button" className="ghost-action small" onClick={() => void handleUpdateClinicAppointmentStatus(appointment.id, 3)}>Iniciar</button>
                                <button type="button" className="ghost-action small" onClick={() => void handleUpdateClinicAppointmentStatus(appointment.id, 4)}>Concluir</button>
                              </div>
                            </div>
                          ))}
                        </div>
                      </article>
                    </section>
                  )}

                  {activeMenu === "records" && (
                    <section className="clinic-module-grid">
                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Prontuários</p>
                            <h2>Escolha o paciente</h2>
                          </div>
                        </div>
                        <div className="message-list">
                          {clinicPatients.map((patient) => (
                            <button key={patient.id} type="button" className={patient.id === selectedClinicPatient?.id ? "list-card active" : "list-card"} onClick={() => setSelectedClinicPatientId(patient.id)}>
                              <div className="list-card-top">
                                <strong>{patient.fullName}</strong>
                                <span className="badge blue">{patient.insurance}</span>
                              </div>
                              <p>{patient.notes || "Sem notas clínicas adicionais"}</p>
                            </button>
                          ))}
                        </div>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">IA clínica</p>
                            <h2>Resumo do paciente</h2>
                          </div>
                        </div>
                        <div className="module-list">
                          <button type="button" onClick={() => selectedClinicPatient && void handleGenerateClinicPatientSummary(selectedClinicPatient.id)} disabled={!selectedClinicPatient}>
                            Gerar resumo de IA
                          </button>
                          {clinicPatientSummary ? (
                            <>
                              <div className="module-list-item"><span className="alert-dot blue" /><strong>{clinicPatientSummary.clinicalSummary}</strong></div>
                              <div className="module-list-item"><span className="alert-dot yellow" /><strong>{clinicPatientSummary.attentionPoints}</strong></div>
                              <div className="module-list-item"><span className="alert-dot green" /><strong>{clinicPatientSummary.suggestedNextSteps}</strong></div>
                            </>
                          ) : null}
                        </div>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Histórico</p>
                            <h2>Consultas do paciente</h2>
                          </div>
                        </div>
                        <div className="module-list">
                          {clinicAppointments.filter((appointment) => appointment.patientId === selectedClinicPatient?.id).map((appointment) => (
                            <div className="module-list-item" key={appointment.id}>
                              <span className={`alert-dot ${appointmentTone(appointment.status)}`} />
                              <strong>{formatDateTime(appointment.startAtUtc, t.locale)} · {appointment.professionalName} · {appointmentStatusLabel(appointment.status)}</strong>
                            </div>
                          ))}
                        </div>
                      </article>
                    </section>
                  )}

                  {activeMenu === "finance" && (
                    <section className="clinic-module-grid">
                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Financeiro</p>
                            <h2>Resumo atual</h2>
                          </div>
                        </div>
                        <div className="module-list">
                          <div className="module-list-item"><span className="alert-dot green" /><strong>{formatCurrency(clinicSummary?.revenueMonth ?? 0, t.locale)} de receita no mês</strong></div>
                          <div className="module-list-item"><span className="alert-dot blue" /><strong>{clinicSummary?.appointmentsToday ?? 0} consultas planeadas hoje</strong></div>
                          <div className="module-list-item"><span className="alert-dot pink" /><strong>{clinicSummary?.noShowRate ?? 0}% de taxa de faltas</strong></div>
                          <div className="card-actions">
                            <button type="button" className="mini-soft green-soft" onClick={() => setActiveMenu("reports")}>Ver relatório</button>
                            <button type="button" className="mini-soft yellow-soft" onClick={() => setActiveMenu("insurance")}>Ver convênios</button>
                          </div>
                        </div>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Recebimentos</p>
                            <h2>Leitura executiva</h2>
                          </div>
                        </div>
                        <div className="finance-visual">
                          <div className="finance-bars">
                            {[14, 22, 19, 31, 26, 30].map((value, index) => (
                              <div className="finance-bar-column" key={value + index}>
                                <div className="finance-bar-track"><div className="finance-bar-fill" style={{ height: `${value * 3}px` }} /></div>
                                <span>{["S", "T", "Q", "Q", "S", "S"][index]}</span>
                              </div>
                            ))}
                          </div>
                          <div className="finance-donut"><div className="finance-donut-hole">{clinicSummary?.activePatients ?? 0}</div></div>
                        </div>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Pendências</p>
                            <h2>O que rever</h2>
                          </div>
                        </div>
                        <div className="module-list">
                          <div className="module-list-item"><span className="alert-dot yellow" /><strong>3 convénios aguardam conferência</strong></div>
                          <div className="module-list-item"><span className="alert-dot pink" /><strong>2 cobranças precisam de contacto</strong></div>
                          <div className="module-list-item"><span className="alert-dot blue" /><strong>Receita média por consulta em revisão</strong></div>
                        </div>
                      </article>
                    </section>
                  )}

                  {activeMenu === "permissions" && (
                    <section className="clinic-module-grid">
                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Acessos</p>
                            <h2>Utilizadores autorizados</h2>
                          </div>
                        </div>
                        <div className="access-list">
                          {accessMembers.map((member) => (
                            <div className="access-card" key={member.id}>
                              <div className="access-top">
                                <div className="access-avatar">{userInitials(member.fullName)}</div>
                                <div>
                                  <strong>{member.fullName}</strong>
                                  <p>{member.email}</p>
                                  <p className="small-text">{translateRole(member.role, t)}</p>
                                </div>
                              </div>
                              <div className="permission-wrap">
                                {permissionPills(member, t).map((permission) => (
                                  <span className="mini-badge" key={permission}>{permission}</span>
                                ))}
                              </div>
                              <div className="card-actions">
                                <button type="button" className="mini-soft blue-soft" onClick={() => setAccessForm((current) => ({ ...current, fullName: member.fullName, email: member.email, role: member.role }))}>Modificar</button>
                                <button type="button" className="mini-soft pink-soft" onClick={() => setSuccess(`Revise o acesso de ${member.fullName} antes de remover.`)}>Remover</button>
                              </div>
                            </div>
                          ))}
                        </div>
                      </article>

                      <article className="panel clinic-panel module-card">
                        <div className="panel-header compact">
                          <div>
                            <p className="panel-kicker">Novo acesso</p>
                            <h2>Autorizar colaborador</h2>
                          </div>
                        </div>
                        <form className="stack-form" onSubmit={handleCreateAccessMember}>
                          <input value={accessForm.fullName} onChange={(event) => setAccessForm((current) => ({ ...current, fullName: event.target.value }))} placeholder={t.collaboratorNamePlaceholder} disabled={!canManageClinicAccess} />
                          <input value={accessForm.email} onChange={(event) => setAccessForm((current) => ({ ...current, email: event.target.value }))} placeholder={t.collaboratorEmailPlaceholder} disabled={!canManageClinicAccess} />
                          <select value={accessForm.role} onChange={(event) => setAccessForm((current) => ({ ...current, role: event.target.value }))} disabled={!canManageClinicAccess}>
                            <option value="ClinicAdmin">{t.roles.clinicAdmin}</option>
                            <option value="Staff">{t.roles.staff}</option>
                          </select>
                          <div className="checkbox-grid">
                            <label><input type="checkbox" checked={accessForm.canViewDashboard} onChange={(event) => setAccessForm((current) => ({ ...current, canViewDashboard: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsDashboard}</label>
                            <label><input type="checkbox" checked={accessForm.canViewBilling} onChange={(event) => setAccessForm((current) => ({ ...current, canViewBilling: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsBilling}</label>
                            <label><input type="checkbox" checked={accessForm.canManagePatients} onChange={(event) => setAccessForm((current) => ({ ...current, canManagePatients: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsPatients}</label>
                            <label><input type="checkbox" checked={accessForm.canManageSchedule} onChange={(event) => setAccessForm((current) => ({ ...current, canManageSchedule: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsSchedule}</label>
                            <label><input type="checkbox" checked={accessForm.canManageSettings} onChange={(event) => setAccessForm((current) => ({ ...current, canManageSettings: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsSettings}</label>
                          </div>
                          <button disabled={!canManageClinicAccess}>{t.collaboratorCreateAction}</button>
                        </form>
                      </article>
                    </section>
                  )}

                  {!["agenda", "patients", "doctors", "attendance", "records", "finance", "permissions"].includes(activeMenu) && (
                    <section className="clinic-module-grid">
                      {currentClinicPage.columns.map((column) => (
                        <article className="panel clinic-panel module-card" key={column.title}>
                          <div className="panel-header compact">
                            <div>
                              <p className="panel-kicker">Área interna</p>
                              <h2>{column.title}</h2>
                            </div>
                          </div>
                          <div className="module-list">
                            {column.items.map((item) => (
                              <div className="module-list-item" key={item}>
                                <span className="alert-dot blue" />
                                <strong>{item}</strong>
                              </div>
                            ))}
                          </div>
                        </article>
                      ))}
                    </section>
                  )}
                </section>
              </>
            )}
          </section>
        </section>
      </main>
    );
  }

  const summaryCards = dashboard
    ? [
        { label: t.summaryClients, value: String(currentUser.role === "platform_admin" ? dashboard.totalClients : visibleClients.length) },
        { label: t.summaryPaid, value: String(dashboard.activeClients) },
        { label: t.summaryOverdue, value: String(dashboard.overdueClients) },
        { label: t.summaryMrr, value: formatCurrency(dashboard.mrr, t.locale) }
      ]
    : [];

  return (
    <main className="shell">
      <section className="app-frame">
        <aside className="sidebar">
          <div className="sidebar-brand">
            <div className="sidebar-logo">CF</div>
            <div>
              <p>{t.brandingName}</p>
              <span>{t.brandingTagline}</span>
            </div>
          </div>

          <div className="sidebar-stack">
            {menuSections.map((section) => (
              <div className="sidebar-group" key={section.title}>
                <p className="sidebar-title">{section.title}</p>
                <div className="sidebar-items">
                  {section.items.map((item) => {
                    const allowed = allowedPermissions.includes(item.permission);
                    const isActive = activeMenu === item.permission;

                    return (
                      <button
                        key={item.label}
                        type="button"
                        className={isActive ? "sidebar-item active" : allowed ? "sidebar-item" : "sidebar-item locked"}
                        disabled={!allowed}
                        onClick={() => setActiveMenu(item.permission)}
                        title={allowed ? item.label : t.menuLockedLabel}
                      >
                        <span>{item.label}</span>
                        {!allowed ? <small>{t.menuLockedLabel}</small> : null}
                      </button>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>

          <div className="sidebar-foot">
            <span>{t.sidebarFooterLabel}</span>
            <strong>{t.sidebarFooterTitle}</strong>
            <label className="language-field">
              <span>{t.languageFieldLabel}</span>
              <select value={language} onChange={(event) => setLanguage(event.target.value as typeof language)}>
                {availableLanguages.map((option) => (
                  <option key={option.code} value={option.code}>
                    {option.label}
                  </option>
                ))}
              </select>
            </label>
          </div>
        </aside>

        <section className="page">
          <div className="page-topbar">
            <div className="topbar-copy">
              <p className="eyebrow">{t.headerEyebrow}</p>
              <strong>{t.topbarGreeting}</strong>
            </div>
            <div className="session-card">
              <div className="session-avatar">{userInitials(currentUser.name)}</div>
              <div className="session-meta">
                <strong>{currentUser.name}</strong>
                <span>{currentUser.email}</span>
                <span>{translateAppRole(currentUser.role, t)}</span>
              </div>
              <button type="button" className="ghost-action small" onClick={handleLogout}>
                {t.topbarLogout}
              </button>
            </div>
          </div>

          <header className="masthead">
            <div className="masthead-copy">
              <p className="eyebrow">{t.headerEyebrow}</p>
              <h1>{t.headerTitle}</h1>
              <p>{t.headerDescription}</p>
            </div>
          </header>

          <section className="summary-grid">
            {summaryCards.map((card) => (
              <article className="summary-card" key={card.label}>
                <span>{card.label}</span>
                <strong>{card.value}</strong>
              </article>
            ))}
          </section>

          <div className="status-row">
            <span className="status-chip blue">{isLoading ? t.loadingData : t.backendConnected}</span>
            {dashboard ? <span className="status-chip yellow">{t.nearingCutoff(dashboard.expiringThisWeek)}</span> : null}
            {success ? <span className="status-text success">{success}</span> : null}
            {error ? <span className="status-text error">{error}</span> : null}
          </div>

          <section className="layout-grid">
            <article className="panel panel-scroll">
              <div className="panel-header">
                <div>
                  <p className="panel-kicker">{t.clientsKicker}</p>
                  <h2>{t.clientsTitle}</h2>
                </div>
              </div>

              <div className="list-stack">
                {visibleClients.map((client) => (
                  <button
                    key={client.id}
                    type="button"
                    className={client.id === selectedClient?.id ? "list-card active" : "list-card"}
                    onClick={() => setSelectedClientId(client.id)}
                  >
                    <div className="list-card-top">
                      <strong>{client.clinicName}</strong>
                      <span className={`badge ${statusTone(client.billingStatus)}`}>{getLocalizedBillingStatus(client.billingStatus, t)}</span>
                    </div>
                    <p>{client.clientCode} · {client.planName}</p>
                    <p>{client.ownerName} · {client.ownerEmail}</p>
                    <p className="small-text">{translateLastPaymentLabel(client.lastPaymentLabel, t)}</p>
                  </button>
                ))}
              </div>
            </article>

            <section className="detail-column">
              <article className="panel">
                <div className="panel-header">
                  <div>
                    <p className="panel-kicker">{t.selectedAccountKicker}</p>
                    <h2>{selectedClient?.clinicName ?? t.selectClientTitle}</h2>
                  </div>
                  {selectedClient ? (
                    <span className={`badge ${statusTone(selectedClient.billingStatus)}`}>
                      {getLocalizedBillingStatus(selectedClient.billingStatus, t)}
                    </span>
                  ) : null}
                </div>

                {selectedClient ? (
                  <div className="detail-grid">
                    <div className="detail-item">
                      <span>{t.clientCodeLabel}</span>
                      <strong>{selectedClient.clientCode}</strong>
                    </div>
                    <div className="detail-item">
                      <span>{t.ownerLabel}</span>
                      <strong>{selectedClient.ownerName}</strong>
                    </div>
                    <div className="detail-item">
                      <span>{t.planLabel}</span>
                      <strong>{selectedClient.planName}</strong>
                    </div>
                    <div className="detail-item">
                      <span>{t.monthlyFeeLabel}</span>
                      <strong>{formatCurrency(selectedClient.monthlyAmount, t.locale)}</strong>
                    </div>
                    <div className="detail-item">
                      <span>{t.dueDateLabel}</span>
                      <strong>{formatDate(selectedClient.dueDate, t.locale)}</strong>
                    </div>
                    <div className="detail-item">
                      <span>{t.cutoffLabel}</span>
                      <strong>{cutoffLabel(selectedClient.daysUntilCutoff, t)}</strong>
                    </div>
                    <div className="detail-item">
                      <span>{t.lastStatusLabel}</span>
                      <strong>{translateLastPaymentLabel(selectedClient.lastPaymentLabel, t)}</strong>
                    </div>
                    <div className="detail-item">
                      <span>{t.accessResponsibleLabel}</span>
                      <strong>{selectedClient.ownerEmail}</strong>
                    </div>
                  </div>
                ) : null}

                {selectedClient && currentUser.role === "platform_admin" ? (
                  <div className="action-row">
                    <button onClick={() => void handleGiftMonth(selectedClient.id)}>{t.giftMonthAction}</button>
                    <button className="soft-yellow" onClick={() => void handleSuspend(selectedClient.id)}>{t.suspendAction}</button>
                    <button className="soft-pink" onClick={() => void handleDelete(selectedClient.id)}>{t.deleteAction}</button>
                  </div>
                ) : null}
              </article>

              <article className="panel">
                <div className="panel-header">
                  <div>
                    <p className="panel-kicker">{t.internalNoteKicker}</p>
                    <h2>{t.internalNoteTitle}</h2>
                  </div>
                </div>

                <form className="stack-form" onSubmit={handleSaveNote}>
                  <textarea
                    rows={5}
                    value={draftNote}
                    onChange={(event) => setDraftNote(event.target.value)}
                    placeholder={t.internalNotePlaceholder}
                    disabled={!selectedClient || !allowedPermissions.includes("notes")}
                  />
                  <button disabled={!selectedClient || !allowedPermissions.includes("notes")}>{t.saveNoteAction}</button>
                </form>
              </article>

              <article className="panel">
                <div className="panel-header">
                  <div>
                    <p className="panel-kicker">{t.accessKicker}</p>
                    <h2>{t.accessTitle}</h2>
                  </div>
                </div>

                <div className="access-list">
                  {accessMembers.length === 0 ? (
                    <p className="small-text">{t.accessEmpty}</p>
                  ) : (
                    accessMembers.map((member) => (
                      <div className="access-card" key={member.id}>
                        <div className="access-top">
                          <div className="access-avatar">{userInitials(member.fullName)}</div>
                          <div>
                            <strong>{member.fullName}</strong>
                            <p>{member.email}</p>
                            <p className="small-text">{translateRole(member.role, t)}</p>
                          </div>
                        </div>
                        <div className="permission-wrap">
                          {permissionPills(member, t).map((permission) => (
                            <span className="mini-badge" key={permission}>{permission}</span>
                          ))}
                        </div>
                      </div>
                    ))
                  )}
                </div>

                <form className="stack-form access-form" onSubmit={handleCreateAccessMember}>
                  <p className="panel-kicker auth-kicker">{t.accessFormTitle}</p>
                  <input
                    value={accessForm.fullName}
                    onChange={(event) => setAccessForm((current) => ({ ...current, fullName: event.target.value }))}
                    placeholder={t.collaboratorNamePlaceholder}
                    disabled={!canManageClinicAccess}
                  />
                  <input
                    value={accessForm.email}
                    onChange={(event) => setAccessForm((current) => ({ ...current, email: event.target.value }))}
                    placeholder={t.collaboratorEmailPlaceholder}
                    disabled={!canManageClinicAccess}
                  />
                  <select
                    value={accessForm.role}
                    onChange={(event) => setAccessForm((current) => ({ ...current, role: event.target.value }))}
                    disabled={!canManageClinicAccess}
                  >
                    <option value="ClinicAdmin">{t.roles.clinicAdmin}</option>
                    <option value="Staff">{t.roles.staff}</option>
                  </select>

                  <div className="checkbox-grid">
                    <label><input type="checkbox" checked={accessForm.canViewDashboard} onChange={(event) => setAccessForm((current) => ({ ...current, canViewDashboard: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsDashboard}</label>
                    <label><input type="checkbox" checked={accessForm.canViewBilling} onChange={(event) => setAccessForm((current) => ({ ...current, canViewBilling: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsBilling}</label>
                    <label><input type="checkbox" checked={accessForm.canManagePatients} onChange={(event) => setAccessForm((current) => ({ ...current, canManagePatients: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsPatients}</label>
                    <label><input type="checkbox" checked={accessForm.canManageSchedule} onChange={(event) => setAccessForm((current) => ({ ...current, canManageSchedule: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsSchedule}</label>
                    <label><input type="checkbox" checked={accessForm.canManageSettings} onChange={(event) => setAccessForm((current) => ({ ...current, canManageSettings: event.target.checked }))} disabled={!canManageClinicAccess} /> {t.permissionsSettings}</label>
                  </div>

                  <button disabled={!canManageClinicAccess || !selectedClient}>{t.collaboratorCreateAction}</button>
                </form>
              </article>
            </section>

            <section className="detail-column">
              <article className="panel">
                <div className="panel-header">
                  <div>
                    <p className="panel-kicker">{t.remindersKicker}</p>
                    <h2>{t.remindersTitle}</h2>
                  </div>
                </div>

                <form className="stack-form" onSubmit={handleSendMessage}>
                  <select
                    value={messageForm.clientId}
                    onChange={(event) => setMessageForm((current) => ({ ...current, clientId: event.target.value }))}
                    disabled={!allowedPermissions.includes("messages")}
                  >
                    <option value="">{t.selectClientOption}</option>
                    {visibleClients.map((client) => (
                      <option key={client.id} value={client.id}>{client.clinicName}</option>
                    ))}
                  </select>

                  <select
                    value={messageForm.channel}
                    onChange={(event) => setMessageForm((current) => ({ ...current, channel: event.target.value }))}
                    disabled={!allowedPermissions.includes("messages")}
                  >
                    <option value="Email">{t.channels.email}</option>
                    <option value="WhatsApp">{t.channels.whatsapp}</option>
                  </select>

                  <input
                    value={messageForm.subject}
                    onChange={(event) => setMessageForm((current) => ({ ...current, subject: event.target.value }))}
                    placeholder={t.subjectPlaceholder}
                    disabled={!allowedPermissions.includes("messages")}
                  />

                  <textarea
                    rows={5}
                    value={messageForm.body}
                    onChange={(event) => setMessageForm((current) => ({ ...current, body: event.target.value }))}
                    placeholder={t.messagePlaceholder}
                    disabled={!allowedPermissions.includes("messages")}
                  />

                  <button disabled={!messageForm.clientId || !allowedPermissions.includes("messages")}>{t.sendReminderAction}</button>
                </form>
              </article>

              <article className="panel panel-scroll">
                <div className="panel-header">
                  <div>
                    <p className="panel-kicker">{t.messagesKicker}</p>
                    <h2>{t.messagesTitle}</h2>
                  </div>
                </div>

                <div className="message-list">
                  {messages
                    .filter((message) => currentUser.role === "platform_admin" || message.clientId === currentUser.clientId)
                    .map((message) => (
                      <div className="message-card" key={message.id}>
                        <div className="message-top">
                          <strong>{message.clinicName}</strong>
                          <span>{translateChannel(message.channel, t)}</span>
                        </div>
                        <p>{message.subject}</p>
                        <p className="small-text">{message.body}</p>
                        <p className="small-text">{formatDateTime(message.sentAtUtc, t.locale)}</p>
                      </div>
                    ))}
                </div>
              </article>
            </section>
          </section>
        </section>
      </section>
    </main>
  );
}
