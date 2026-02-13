using System.Text.Json;
using GarageSales.Api.Models;

namespace GarageSales.Api.Services;

public class UserStore
{
    private readonly string _filePath;
    private readonly SemaphoreSlim _mutex = new(1, 1);
    private readonly JsonSerializerOptions _jsonOptions = new() { WriteIndented = true };

    public UserStore(IHostEnvironment environment)
    {
        var dataDir = Path.Combine(environment.ContentRootPath, "App_Data");
        Directory.CreateDirectory(dataDir);
        _filePath = Path.Combine(dataDir, "users.json");
    }

    public async Task<UserAccount?> FindByEmailAsync(string email)
    {
        var normalized = NormalizeEmail(email);
        var users = await ReadAllAsync();
        return users.FirstOrDefault(u => u.Email == normalized);
    }

    public async Task<UserAccount?> FindByIdAsync(string userId)
    {
        var users = await ReadAllAsync();
        return users.FirstOrDefault(u => u.Id == userId);
    }

    public async Task<UserAccount> CreateAsync(string name, string email, string phone, string passwordHash)
    {
        await _mutex.WaitAsync();
        try
        {
            var users = await ReadAllInternalAsync();
            var normalizedEmail = NormalizeEmail(email);
            if (users.Any(u => u.Email == normalizedEmail))
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

            users.Add(user);
            await WriteAllInternalAsync(users);
            return user;
        }
        finally
        {
            _mutex.Release();
        }
    }

    private async Task<List<UserAccount>> ReadAllAsync()
    {
        await _mutex.WaitAsync();
        try
        {
            return await ReadAllInternalAsync();
        }
        finally
        {
            _mutex.Release();
        }
    }

    private async Task<List<UserAccount>> ReadAllInternalAsync()
    {
        if (!File.Exists(_filePath))
        {
            return new List<UserAccount>();
        }

        await using var stream = File.OpenRead(_filePath);
        var users = await JsonSerializer.DeserializeAsync<List<UserAccount>>(stream);
        return users ?? new List<UserAccount>();
    }

    private async Task WriteAllInternalAsync(List<UserAccount> users)
    {
        await using var stream = File.Create(_filePath);
        await JsonSerializer.SerializeAsync(stream, users, _jsonOptions);
    }

    private static string NormalizeEmail(string email) => email.Trim().ToLowerInvariant();
}
