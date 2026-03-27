using ClinicFlow.Domain.Enums;

namespace ClinicFlow.Domain.Entities;

public sealed class Appointment
{
    public Guid Id { get; init; }
    public Guid TenantId { get; init; }
    public Guid PatientId { get; init; }
    public Guid ProfessionalId { get; init; }
    public string ClinicUnitName { get; init; } = string.Empty;
    public DateTime StartAtUtc { get; init; }
    public DateTime EndAtUtc { get; init; }
    public AppointmentStatus Status { get; set; } = AppointmentStatus.Scheduled;
    public string Source { get; init; } = "Manual";
    public string Notes { get; init; } = string.Empty;
    public string? CancellationReason { get; set; }
    public int NoShowRiskScore { get; init; }
}
