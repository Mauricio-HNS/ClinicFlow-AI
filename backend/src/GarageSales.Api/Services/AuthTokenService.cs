using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace GarageSales.Api.Services;

public record AuthPrincipal(string UserId, string Email, string Name, DateTime ExpiresAtUtc);

public class AuthTokenService
{
    private readonly byte[] _keyBytes;
    private readonly TimeSpan _ttl;

    public AuthTokenService(IConfiguration configuration)
    {
        var secret = configuration["Auth:Secret"];
        if (string.IsNullOrWhiteSpace(secret))
        {
            secret = "garage-sales-dev-secret-change-in-production";
        }

        _keyBytes = Encoding.UTF8.GetBytes(secret);
        _ttl = TimeSpan.FromDays(7);
    }

    public string CreateToken(string userId, string email, string name)
    {
        var headerJson = JsonSerializer.Serialize(new Dictionary<string, object>
        {
            ["alg"] = "HS256",
            ["typ"] = "JWT"
        });
        var exp = DateTimeOffset.UtcNow.Add(_ttl).ToUnixTimeSeconds();
        var payloadJson = JsonSerializer.Serialize(new Dictionary<string, object>
        {
            ["sub"] = userId,
            ["email"] = email,
            ["name"] = name,
            ["exp"] = exp
        });

        var header = Base64UrlEncode(Encoding.UTF8.GetBytes(headerJson));
        var payload = Base64UrlEncode(Encoding.UTF8.GetBytes(payloadJson));
        var unsigned = $"{header}.{payload}";
        var signature = Base64UrlEncode(Sign(unsigned));
        return $"{unsigned}.{signature}";
    }

    public AuthPrincipal? ValidateToken(string token)
    {
        var parts = token.Split('.');
        if (parts.Length != 3)
        {
            return null;
        }

        var unsigned = $"{parts[0]}.{parts[1]}";
        var expectedSignature = Base64UrlEncode(Sign(unsigned));
        if (!FixedTimeEquals(parts[2], expectedSignature))
        {
            return null;
        }

        try
        {
            var payloadJson = Encoding.UTF8.GetString(Base64UrlDecode(parts[1]));
            var payload = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(payloadJson);
            if (payload is null)
            {
                return null;
            }

            var userId = payload.TryGetValue("sub", out var sub) ? sub.GetString() : null;
            var email = payload.TryGetValue("email", out var mail) ? mail.GetString() : null;
            var name = payload.TryGetValue("name", out var n) ? n.GetString() : null;
            var exp = payload.TryGetValue("exp", out var expValue) ? expValue.GetInt64() : 0;
            var expiresAt = DateTimeOffset.FromUnixTimeSeconds(exp).UtcDateTime;

            if (string.IsNullOrWhiteSpace(userId) || string.IsNullOrWhiteSpace(email))
            {
                return null;
            }

            if (expiresAt <= DateTime.UtcNow)
            {
                return null;
            }

            return new AuthPrincipal(userId, email, name ?? string.Empty, expiresAt);
        }
        catch
        {
            return null;
        }
    }

    private byte[] Sign(string content)
    {
        using var hmac = new HMACSHA256(_keyBytes);
        return hmac.ComputeHash(Encoding.UTF8.GetBytes(content));
    }

    private static string Base64UrlEncode(byte[] bytes)
    {
        return Convert.ToBase64String(bytes).Replace('+', '-').Replace('/', '_').TrimEnd('=');
    }

    private static byte[] Base64UrlDecode(string text)
    {
        var padded = text.Replace('-', '+').Replace('_', '/');
        switch (padded.Length % 4)
        {
            case 2:
                padded += "==";
                break;
            case 3:
                padded += "=";
                break;
        }
        return Convert.FromBase64String(padded);
    }

    private static bool FixedTimeEquals(string a, string b)
    {
        var aBytes = Encoding.UTF8.GetBytes(a);
        var bBytes = Encoding.UTF8.GetBytes(b);
        return CryptographicOperations.FixedTimeEquals(aBytes, bBytes);
    }
}
