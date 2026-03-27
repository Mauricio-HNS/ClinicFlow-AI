namespace ClinicFlow.Application.Contracts;

public sealed record PatientDto(
    Guid Id,
    Guid TenantId,
    string FullName,
    DateOnly BirthDate,
    string Gender,
    string Phone,
    string Email,
    string Insurance,
    string Notes);

public sealed record CreatePatientRequest(
    string FullName,
    DateOnly BirthDate,
    string Gender,
    string Phone,
    string Email,
    string Document,
    string Insurance,
    string Notes);
