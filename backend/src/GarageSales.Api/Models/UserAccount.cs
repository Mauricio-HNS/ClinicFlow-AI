namespace GarageSales.Api.Models;

public class UserAccount
{
    public required string Id { get; init; }
    public required string Name { get; set; }
    public required string Email { get; init; }
    public required string Phone { get; set; }
    public required string PasswordHash { get; set; }
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
}
