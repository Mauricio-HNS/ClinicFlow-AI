using ClinicFlow.Domain.Enums;

namespace ClinicFlow.Domain.Entities;

public sealed class User
{
    public Guid Id { get; init; }
    public Guid TenantId { get; init; }
    public string FullName { get; init; } = string.Empty;
    public string Email { get; init; } = string.Empty;
    public UserRole Role { get; init; }
    public bool Active { get; init; } = true;
}
