namespace GarageSales.Api.Models;

public class FavoriteItem
{
    public required string OwnerUserId { get; init; }
    public required string ListingId { get; init; }
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
}
