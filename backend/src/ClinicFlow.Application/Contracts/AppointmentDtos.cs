using ClinicFlow.Domain.Enums;

namespace ClinicFlow.Application.Contracts;

public sealed record AppointmentDto(
    Guid Id,
    Guid TenantId,
    Guid PatientId,
    string PatientName,
    Guid ProfessionalId,
    string ProfessionalName,
    string ClinicUnitName,
    DateTime StartAtUtc,
    DateTime EndAtUtc,
    AppointmentStatus Status,
    int NoShowRiskScore);

public sealed record CreateAppointmentRequest(
    Guid PatientId,
    Guid ProfessionalId,
    string ClinicUnitName,
    DateTime StartAtUtc,
    string Notes);

public sealed record UpdateAppointmentStatusRequest(AppointmentStatus Status, string? CancellationReason);
