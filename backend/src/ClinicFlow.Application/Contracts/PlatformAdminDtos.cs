namespace ClinicFlow.Application.Contracts;

public sealed record PlatformDashboardDto(
    int TotalClients,
    int ActiveClients,
    int OverdueClients,
    int SuspendedClients,
    decimal Mrr,
    int ExpiringThisWeek);

public sealed record PlatformClientDto(
    Guid Id,
    string ClientCode,
    string ClinicName,
    string PlanName,
    decimal MonthlyAmount,
    string BillingStatus,
    DateOnly DueDate,
    int DaysUntilCutoff,
    bool IsSuspended,
    string OwnerName,
    string OwnerEmail,
    string LastPaymentLabel,
    string Notes);

public sealed record UpdatePlatformClientNoteRequest(string Notes);

public sealed record PlatformMessageDto(
    Guid Id,
    Guid ClientId,
    string ClinicName,
    string Channel,
    string Subject,
    string Body,
    DateTime SentAtUtc);

public sealed record SendPlatformMessageRequest(
    Guid ClientId,
    string Channel,
    string Subject,
    string Body);

public sealed record PlatformAccessMemberDto(
    Guid Id,
    Guid ClientId,
    string FullName,
    string Email,
    string Role,
    bool CanViewDashboard,
    bool CanViewBilling,
    bool CanManagePatients,
    bool CanManageSchedule,
    bool CanManageSettings,
    bool IsActive);

public sealed record CreatePlatformAccessMemberRequest(
    string FullName,
    string Email,
    string Role,
    bool CanViewDashboard,
    bool CanViewBilling,
    bool CanManagePatients,
    bool CanManageSchedule,
    bool CanManageSettings);
