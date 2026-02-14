using GarageSales.Api.Data;
using GarageSales.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace GarageSales.Api.Services;

public class UserStore
{
    private readonly AppDbContext _db;

    public UserStore(AppDbContext db)
    {
        _db = db;
    }

    public async Task<UserAccount?> FindByEmailAsync(string email)
    {
        var normalized = NormalizeEmail(email);
        return await _db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Email == normalized);
    }

    public async Task<UserAccount?> FindByIdAsync(string userId)
    {
        return await _db.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == userId);
    }

    public async Task<UserAccount> CreateAsync(string name, string email, string phone, string passwordHash)
    {
        var normalizedEmail = NormalizeEmail(email);
        var exists = await _db.Users.AnyAsync(u => u.Email == normalizedEmail);
        if (exists)
        {
            throw new InvalidOperationException("EMAIL_EXISTS");
        }

        var user = new UserAccount
        {
            Id = Guid.NewGuid().ToString("N"),
            Name = name.Trim(),
            Email = normalizedEmail,
            Phone = phone.Trim(),
            PasswordHash = passwordHash,
            CreatedAtUtc = DateTime.UtcNow
        };

        _db.Users.Add(user);
        await _db.SaveChangesAsync();
        return user;
    }

    private static string NormalizeEmail(string email) => email.Trim().ToLowerInvariant();
}
