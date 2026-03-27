using ClinicFlow.Domain.Enums;

namespace ClinicFlow.Domain.Entities;

public sealed class Tenant
{
    public Guid Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public string Plan { get; init; } = string.Empty;
    public TenantStatus Status { get; init; } = TenantStatus.Trial;
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
}
