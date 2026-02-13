namespace GarageSales.Api.Contracts;

public record JobApplicationCreateRequest(
    string JobId,
    string JobTitle,
    string Company,
    string CandidateName,
    string CandidatePhone,
    string? Message);

public record JobApplicationDto(
    string Id,
    string JobId,
    string JobTitle,
    string Company,
    string CandidateName,
    string CandidatePhone,
    string? Message,
    DateTime CreatedAtUtc);
