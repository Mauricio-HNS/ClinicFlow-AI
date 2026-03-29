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
  const [activeMenu, setActiveMenu] = useState<MenuPermission>("clients");
  const [dashboard, setDashboard] = useState<PlatformDashboard | null>(null);
  const [clients, setClients] = useState<PlatformClient[]>([]);
  const [messages, setMessages] = useState<PlatformMessage[]>([]);
  const [accessMembers, setAccessMembers] = useState<PlatformAccessMember[]>([]);
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

  if (currentUser.role !== "platform_admin") {
    const clinicMenu = [
      { label: "Dashboard", enabled: true },
      { label: "Agenda", enabled: clinicAccessProfile?.canManageSchedule ?? false },
      { label: "Pacientes", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { label: "Médicos", enabled: clinicAccessProfile?.canManageSchedule ?? false },
      { label: "Atendimentos", enabled: clinicAccessProfile?.canViewDashboard ?? false },
      { label: "Prontuários", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { label: "Financeiro", enabled: clinicAccessProfile?.canViewBilling ?? false },
      { label: "Convênios", enabled: clinicAccessProfile?.canViewBilling ?? false },
      { label: "Exames", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { label: "Prescrições", enabled: clinicAccessProfile?.canManagePatients ?? false },
      { label: "Chat / WhatsApp", enabled: true },
      { label: "Relatórios", enabled: clinicAccessProfile?.canViewDashboard ?? false },
      { label: "Configurações", enabled: clinicAccessProfile?.canManageSettings ?? false },
      { label: "Usuários e permissões", enabled: currentUser.role === "clinic_admin" }
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
                  className={item.label === "Dashboard" ? "sidebar-item active" : item.enabled ? "sidebar-item" : "sidebar-item locked"}
                  disabled={!item.enabled}
                  title={item.enabled ? item.label : t.menuLockedLabel}
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

            <section className="clinic-stat-grid">
              {clinicStats.map((card) => (
                <article className={`clinic-stat-card tone-${card.tone}`} key={card.label}>
                  <strong>{card.value}</strong>
                  <span>{card.label}</span>
                </article>
              ))}
            </section>

            <section className="clinic-grid">
              <article className="panel clinic-panel agenda-panel">
                <div className="panel-header">
                  <div>
                    <p className="panel-kicker">Agenda</p>
                    <h2>Agenda do dia</h2>
                  </div>
                </div>

                <div className="schedule-list">
                  {scheduleItems.map((item) => (
                    <div className="schedule-row" key={`${item.time}-${item.patient}`}>
                      <strong>{item.time}</strong>
                      <div>
                        <p>{item.patient}</p>
                        <span>{item.doctor}</span>
                      </div>
                      <div className="schedule-meta">
                        <span>{item.type}</span>
                        <span className={`inline-status ${item.tone}`}>{item.status}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </article>

              <article className="panel clinic-panel">
                <div className="panel-header">
                  <div>
                    <p className="panel-kicker">Atendimento</p>
                    <h2>Próximos atendimentos</h2>
                  </div>
                </div>

                <div className="next-appointments">
                  {nextAppointments.map((appointment) => (
                    <div className="next-card" key={`${appointment.patient}-${appointment.time}`}>
                      <div className="next-avatar">{appointment.avatar}</div>
                      <div>
                        <strong>{appointment.patient}</strong>
                        <p>{appointment.time} · {appointment.doctor}</p>
                      </div>
                      <button type="button" className="mini-action" disabled={!(clinicAccessProfile?.canManagePatients ?? false)}>
                        Abrir prontuário
                      </button>
                    </div>
                  ))}
                </div>

                <div className="alert-block">
                  <div className="panel-header compact">
                    <div>
                      <p className="panel-kicker">Atenção</p>
                      <h2>Alertas importantes</h2>
                    </div>
                  </div>

                  <div className="alert-list">
                    {alerts.map((alert) => (
                      <div className="alert-row" key={alert.title}>
                        <span className={`alert-dot ${alert.tone}`} />
                        <strong>{alert.title}</strong>
                      </div>
                    ))}
                  </div>
                </div>
              </article>

              <section className="clinic-side-column">
                <article className="panel clinic-panel">
                  <div className="panel-header">
                    <div>
                      <p className="panel-kicker">Indicadores</p>
                      <h2>Resumo operacional</h2>
                    </div>
                  </div>
                  <div className="mini-chart">
                    {[18, 26, 22, 31, 25, 34, 29].map((value, index) => (
                      <div className="bar-wrap" key={value + index}>
                        <div className="bar" style={{ height: `${value * 2}px` }} />
                        <span>{["S", "T", "Q", "Q", "S", "S", "D"][index]}</span>
                      </div>
                    ))}
                  </div>
                </article>

                <article className="panel clinic-panel">
                  <div className="panel-header compact">
                    <div>
                      <p className="panel-kicker">Ações</p>
                      <h2>Ações rápidas</h2>
                    </div>
                  </div>
                  <div className="quick-action-list">
                    {quickActions.map((action) => (
                      <button
                        key={action.label}
                        type="button"
                        className={`quick-action tone-${action.tone}`}
                        disabled={!action.enabled}
                      >
                        {action.label}
                      </button>
                    ))}
                  </div>
                </article>
              </section>

              <article className="panel clinic-panel suggestion-panel">
                <div className="panel-header compact">
                  <div>
                    <p className="panel-kicker">IA operacional</p>
                    <h2>Sugestão de encaixe</h2>
                  </div>
                </div>
                <div className="suggestion-copy">
                  <p>Horário disponível: <strong>11:45</strong></p>
                  <p>Paciente prioritário: <strong>Laura Martins</strong></p>
                  <p>Profissional sugerido: <strong>Dra. Fernanda</strong></p>
                </div>
              </article>

              <article className="panel clinic-panel forecast-panel">
                <div className="panel-header compact">
                  <div>
                    <p className="panel-kicker">Previsão</p>
                    <h2>Risco de faltas</h2>
                  </div>
                </div>
                <p className="forecast-copy">
                  <strong>15%</strong> de risco estimado para amanhã, com maior atenção nas consultas após as 16:00.
                </p>
              </article>
            </section>
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
