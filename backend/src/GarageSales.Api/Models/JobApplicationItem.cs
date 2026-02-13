namespace GarageSales.Api.Models;

public class JobApplicationItem
{
    public required string Id { get; init; }
    public required string OwnerUserId { get; init; }
    public required string JobId { get; init; }
    public required string JobTitle { get; set; }
    public required string Company { get; set; }
    public required string CandidateName { get; set; }
    public required string CandidatePhone { get; set; }
    public string? Message { get; set; }
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
}
