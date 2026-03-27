using ClinicFlow.Domain.Enums;

namespace ClinicFlow.Application.Contracts;

public sealed record LoginRequest(string Email, string Password, string TenantSlug);

public sealed record LoginResponse(
    string AccessToken,
    Guid TenantId,
    string TenantName,
    Guid UserId,
    string FullName,
    UserRole Role);
