namespace GarageSales.Api.Models;

public class MessageThread
{
    public required string Id { get; init; }
    public required string OwnerUserId { get; init; }
    public required string Title { get; set; }
    public required string Preview { get; set; }
    public required string TimeLabel { get; set; }
    public bool Opened { get; set; }
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
    public DateTime UpdatedAtUtc { get; set; } = DateTime.UtcNow;
}
