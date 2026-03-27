namespace ClinicFlow.Domain.Entities;

public sealed class Professional
{
    public Guid Id { get; init; }
    public Guid TenantId { get; init; }
    public string FullName { get; init; } = string.Empty;
    public string Specialty { get; init; } = string.Empty;
    public string LicenseNumber { get; init; } = string.Empty;
    public int AppointmentDurationMinutes { get; init; } = 30;
    public bool Active { get; init; } = true;
}
