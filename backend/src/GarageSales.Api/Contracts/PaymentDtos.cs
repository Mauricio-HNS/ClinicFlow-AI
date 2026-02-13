namespace GarageSales.Api.Contracts;

public record EventCheckoutRequest(
    string? Currency,
    string? SuccessUrl,
    string? CancelUrl);

public record PaymentCheckoutResponse(
    string PaymentId,
    string Status,
    string Provider,
    decimal Amount,
    string Currency,
    string? CheckoutUrl,
    string? ProviderReference);

public record PaymentRecordDto(
    string Id,
    string Status,
    string Provider,
    decimal Amount,
    string Currency,
    string? ProviderReference,
    DateTime CreatedAtUtc,
    DateTime UpdatedAtUtc);
