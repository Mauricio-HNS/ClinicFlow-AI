namespace ClinicFlow.Application.Contracts;

public sealed record PatientSummaryDto(
    Guid PatientId,
    string ClinicalSummary,
    string AttentionPoints,
    string SuggestedNextSteps);

public sealed record MessageSuggestionDto(
    Guid AppointmentId,
    string Channel,
    string Message);
