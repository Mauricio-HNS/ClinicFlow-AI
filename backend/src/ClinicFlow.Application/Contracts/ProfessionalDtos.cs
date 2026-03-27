namespace ClinicFlow.Application.Contracts;

public sealed record ProfessionalDto(
    Guid Id,
    Guid TenantId,
    string FullName,
    string Specialty,
    string LicenseNumber,
    int AppointmentDurationMinutes,
    bool Active);

public sealed record CreateProfessionalRequest(
    string FullName,
    string Specialty,
    string LicenseNumber,
    int AppointmentDurationMinutes);
