using ClinicFlow.Application.Abstractions;
using ClinicFlow.Application.Contracts;

namespace ClinicFlow.Infrastructure.Persistence;

public sealed class InMemoryPlatformAdminStore : IPlatformAdminStore
{
    private readonly List<PlatformClientDto> _clients;
    private readonly List<PlatformMessageDto> _messages;
    private readonly List<PlatformAccessMemberDto> _accessMembers;

    public InMemoryPlatformAdminStore()
    {
        _clients =
        [
            new PlatformClientDto(
                Id: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870001"),
                ClientCode: "CF-LIS-001",
                ClinicName: "CliniVida Lisboa",
                PlanName: "Growth",
                MonthlyAmount: 249m,
                BillingStatus: "Paid",
                DueDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(21)),
                DaysUntilCutoff: 21,
                IsSuspended: false,
                OwnerName: "Rita Sousa",
                OwnerEmail: "rita@clinivida.pt",
                LastPaymentLabel: "Paid on 24 Mar 2026",
                Notes: "Healthy account. Candidate for annual plan upgrade."),
            new PlatformClientDto(
                Id: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870002"),
                ClientCode: "CF-MAD-014",
                ClinicName: "Centro Med Azul",
                PlanName: "Starter",
                MonthlyAmount: 149m,
                BillingStatus: "Overdue",
                DueDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-4)),
                DaysUntilCutoff: 3,
                IsSuspended: false,
                OwnerName: "Carla Mendes",
                OwnerEmail: "carla@medazul.es",
                LastPaymentLabel: "Invoice overdue by 4 days",
                Notes: "Often pays late. Review before granting new courtesy."),
            new PlatformClientDto(
                Id: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870003"),
                ClientCode: "CF-PT-032",
                ClinicName: "Instituto Serena",
                PlanName: "Scale",
                MonthlyAmount: 399m,
                BillingStatus: "Trial ending",
                DueDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(6)),
                DaysUntilCutoff: 6,
                IsSuspended: false,
                OwnerName: "Marta Nunes",
                OwnerEmail: "marta@serena.pt",
                LastPaymentLabel: "Trial ends in 6 days",
                Notes: "High engagement. Offer assisted onboarding if converted."),
            new PlatformClientDto(
                Id: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870004"),
                ClientCode: "CF-ES-021",
                ClinicName: "Nova Derm Clinic",
                PlanName: "Growth",
                MonthlyAmount: 249m,
                BillingStatus: "Suspended",
                DueDate: DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-12)),
                DaysUntilCutoff: 0,
                IsSuspended: true,
                OwnerName: "Joana Ruiz",
                OwnerEmail: "joana@novaderm.com",
                LastPaymentLabel: "Service suspended on 17 Mar 2026",
                Notes: "Wait for owner answer before deletion.")
        ];

        _messages =
        [
            new PlatformMessageDto(
                Id: Guid.Parse("6cbf12d8-5e43-4c6b-9f10-eaf4b5870101"),
                ClientId: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870002"),
                ClinicName: "Centro Med Azul",
                Channel: "Email",
                Subject: "Payment reminder",
                Body: "Your ClinicFlow subscription is overdue. Please update payment to avoid interruption.",
                SentAtUtc: DateTime.UtcNow.AddHours(-16)),
            new PlatformMessageDto(
                Id: Guid.Parse("6cbf12d8-5e43-4c6b-9f10-eaf4b5870102"),
                ClientId: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870004"),
                ClinicName: "Nova Derm Clinic",
                Channel: "WhatsApp",
                Subject: "Service interruption notice",
                Body: "Service is currently suspended due to unpaid invoices. Reply here when payment is completed.",
                SentAtUtc: DateTime.UtcNow.AddDays(-2))
        ];

        _accessMembers =
        [
            new PlatformAccessMemberDto(
                Id: Guid.Parse("8dbf12d8-5e43-4c6b-9f10-eaf4b5870201"),
                ClientId: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870001"),
                FullName: "Rita Sousa",
                Email: "rita@clinivida.pt",
                Role: "ClinicAdmin",
                CanViewDashboard: true,
                CanViewBilling: true,
                CanManagePatients: true,
                CanManageSchedule: true,
                CanManageSettings: true,
                IsActive: true),
            new PlatformAccessMemberDto(
                Id: Guid.Parse("8dbf12d8-5e43-4c6b-9f10-eaf4b5870202"),
                ClientId: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870001"),
                FullName: "Luisa Ramos",
                Email: "recepcao@clinivida.pt",
                Role: "Staff",
                CanViewDashboard: true,
                CanViewBilling: false,
                CanManagePatients: true,
                CanManageSchedule: true,
                CanManageSettings: false,
                IsActive: true),
            new PlatformAccessMemberDto(
                Id: Guid.Parse("8dbf12d8-5e43-4c6b-9f10-eaf4b5870203"),
                ClientId: Guid.Parse("4abf12d8-5e43-4c6b-9f10-eaf4b5870002"),
                FullName: "Carla Mendes",
                Email: "carla@medazul.es",
                Role: "ClinicAdmin",
                CanViewDashboard: true,
                CanViewBilling: true,
                CanManagePatients: true,
                CanManageSchedule: true,
                CanManageSettings: true,
                IsActive: true)
        ];
    }

    public IReadOnlyList<PlatformClientDto> GetClients() => _clients.ToList();

    public PlatformClientDto? FindClient(Guid clientId) =>
        _clients.FirstOrDefault(x => x.Id == clientId);

    public PlatformClientDto SaveClient(PlatformClientDto client)
    {
        var index = _clients.FindIndex(x => x.Id == client.Id);

        if (index >= 0)
        {
            _clients[index] = client;
        }
        else
        {
            _clients.Add(client);
        }

        return client;
    }

    public bool DeleteClient(Guid clientId)
    {
        var removed = _clients.RemoveAll(x => x.Id == clientId) > 0;
        _messages.RemoveAll(x => x.ClientId == clientId);
        return removed;
    }

    public IReadOnlyList<PlatformMessageDto> GetMessages() => _messages.ToList();

    public PlatformMessageDto AddMessage(PlatformMessageDto message)
    {
        _messages.Add(message);
        return message;
    }

    public IReadOnlyList<PlatformAccessMemberDto> GetAccessMembers(Guid clientId) =>
        _accessMembers.Where(x => x.ClientId == clientId).ToList();

    public PlatformAccessMemberDto AddAccessMember(PlatformAccessMemberDto member)
    {
        _accessMembers.Add(member);
        return member;
    }
}
