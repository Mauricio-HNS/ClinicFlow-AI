namespace GarageSales.Api.Models;

public class ListingItem
{
    public required string Id { get; init; }
    public required string OwnerUserId { get; init; }
    public required string Title { get; set; }
    public required string Category { get; set; }
    public required string Price { get; set; }
    public required string Distance { get; set; }
    public required string Date { get; set; }
    public bool Featured { get; set; }
    public bool IsEvent { get; set; }
    public bool ConsumeEventCredit { get; set; }
    public string? EventPaymentId { get; set; }
    public string? ImageAsset { get; set; }
    public string? ImageUrl { get; set; }
    public double Lat { get; set; }
    public double Lng { get; set; }
    public List<string> PhotoPaths { get; set; } = new();
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
