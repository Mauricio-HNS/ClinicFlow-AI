namespace GarageSales.Api.Models;

public class PaymentRecord
{
    public required string Id { get; init; }
    public required string OwnerUserId { get; init; }
    public required string Status { get; set; }
    public required string Provider { get; init; }
    public required decimal Amount { get; init; }
    public required string Currency { get; init; }
    public string? ProviderReference { get; set; }
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
