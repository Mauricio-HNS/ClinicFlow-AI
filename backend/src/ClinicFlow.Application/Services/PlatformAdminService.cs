using ClinicFlow.Application.Abstractions;
using ClinicFlow.Application.Contracts;

namespace ClinicFlow.Application.Services;

public sealed class PlatformAdminService(IPlatformAdminStore store)
{
    public PlatformDashboardDto GetDashboard()
    {
        var clients = store.GetClients();
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        return new PlatformDashboardDto(
            TotalClients: clients.Count,
            ActiveClients: clients.Count(x => x.BillingStatus == "Paid" && !x.IsSuspended),
            OverdueClients: clients.Count(x => x.BillingStatus == "Overdue"),
            SuspendedClients: clients.Count(x => x.IsSuspended),
            Mrr: clients.Where(x => !x.IsSuspended).Sum(x => x.MonthlyAmount),
            ExpiringThisWeek: clients.Count(x => x.DaysUntilCutoff is >= 0 and <= 7 && x.BillingStatus != "Paid"));
    }

    public IReadOnlyList<PlatformClientDto> GetClients() =>
        store.GetClients()
            .OrderBy(x => x.DaysUntilCutoff)
            .ThenBy(x => x.ClinicName)
            .ToList();

    public IReadOnlyList<PlatformMessageDto> GetMessages() =>
        store.GetMessages()
            .OrderByDescending(x => x.SentAtUtc)
            .ToList();

    public IReadOnlyList<PlatformAccessMemberDto> GetAccessMembers(Guid clientId)
    {
        _ = GetRequiredClient(clientId);

        return store.GetAccessMembers(clientId)
            .OrderByDescending(x => x.Role == "ClinicAdmin")
            .ThenBy(x => x.FullName)
            .ToList();
    }

    public PlatformClientDto GiftOneMonth(Guid clientId)
    {
        var client = GetRequiredClient(clientId);
        var updated = client with
        {
            BillingStatus = "Paid",
            DueDate = client.DueDate.AddMonths(1),
            DaysUntilCutoff = 30,
            IsSuspended = false,
            LastPaymentLabel = "1 month courtesy granted by admin"
        };

        return store.SaveClient(updated);
    }

    public PlatformClientDto SuspendClient(Guid clientId)
    {
        var client = GetRequiredClient(clientId);
        var updated = client with
        {
            BillingStatus = "Suspended",
            IsSuspended = true,
            DaysUntilCutoff = 0
        };

        return store.SaveClient(updated);
    }

    public bool DeleteClient(Guid clientId) => store.DeleteClient(clientId);

    public PlatformClientDto UpdateNote(Guid clientId, UpdatePlatformClientNoteRequest request)
    {
        var client = GetRequiredClient(clientId);
        return store.SaveClient(client with
        {
            Notes = request.Notes.Trim()
        });
    }

    public PlatformMessageDto SendMessage(SendPlatformMessageRequest request)
    {
        var client = GetRequiredClient(request.ClientId);
        var message = new PlatformMessageDto(
            Id: Guid.NewGuid(),
            ClientId: client.Id,
            ClinicName: client.ClinicName,
            Channel: string.IsNullOrWhiteSpace(request.Channel) ? "Email" : request.Channel.Trim(),
            Subject: request.Subject.Trim(),
            Body: request.Body.Trim(),
            SentAtUtc: DateTime.UtcNow);

        store.AddMessage(message);
        return message;
    }

    public PlatformAccessMemberDto AddAccessMember(Guid clientId, CreatePlatformAccessMemberRequest request)
    {
        var client = GetRequiredClient(clientId);

        var member = new PlatformAccessMemberDto(
            Id: Guid.NewGuid(),
            ClientId: client.Id,
            FullName: request.FullName.Trim(),
            Email: request.Email.Trim(),
            Role: string.IsNullOrWhiteSpace(request.Role) ? "Staff" : request.Role.Trim(),
            CanViewDashboard: request.CanViewDashboard,
            CanViewBilling: request.CanViewBilling,
            CanManagePatients: request.CanManagePatients,
            CanManageSchedule: request.CanManageSchedule,
            CanManageSettings: request.CanManageSettings,
            IsActive: true);

        return store.AddAccessMember(member);
    }

    private PlatformClientDto GetRequiredClient(Guid clientId) =>
        store.FindClient(clientId) ?? throw new InvalidOperationException("Client not found.");
}
