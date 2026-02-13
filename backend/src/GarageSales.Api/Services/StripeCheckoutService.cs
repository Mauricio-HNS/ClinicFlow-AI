using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace GarageSales.Api.Services;

public record StripeCheckoutResult(
    string Provider,
    string? CheckoutUrl,
    string? ProviderReference);

public class StripeCheckoutService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    public StripeCheckoutService(IHttpClientFactory httpClientFactory, IConfiguration configuration)
    {
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
    }

    public string ResolveProvider()
    {
        var stripeSecret = _configuration["Payments:Stripe:SecretKey"];
        return string.IsNullOrWhiteSpace(stripeSecret) ? "mock" : "stripe";
    }

    public async Task<StripeCheckoutResult> CreateCheckoutAsync(
        string paymentId,
        string userId,
        decimal amount,
        string currency,
        string? successUrl,
        string? cancelUrl)
    {
        var stripeSecret = _configuration["Payments:Stripe:SecretKey"];
        if (string.IsNullOrWhiteSpace(stripeSecret))
        {
            return new StripeCheckoutResult(
                "mock",
                $"https://checkout.mock.garagesale.local/pay/{paymentId}",
                $"mock-session-{paymentId}");
        }

        var endpoint = "https://api.stripe.com/v1/checkout/sessions";
        var form = new Dictionary<string, string>
        {
            ["mode"] = "payment",
            ["success_url"] = successUrl ?? "https://example.com/payment/success",
            ["cancel_url"] = cancelUrl ?? "https://example.com/payment/cancel",
            ["client_reference_id"] = paymentId,
            ["line_items[0][quantity]"] = "1",
            ["line_items[0][price_data][currency]"] = currency.ToLowerInvariant(),
            ["line_items[0][price_data][unit_amount]"] = ((int)Math.Round(amount * 100m)).ToString(),
            ["line_items[0][price_data][product_data][name]"] = "Publicação de evento",
            ["metadata[payment_id]"] = paymentId,
            ["metadata[user_id]"] = userId
        };

        using var client = _httpClientFactory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", stripeSecret);
        using var content = new FormUrlEncodedContent(form);
        var response = await client.PostAsync(endpoint, content);
        var body = await response.Content.ReadAsStringAsync();
        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException($"Stripe checkout failed: {body}");
        }

        using var doc = JsonDocument.Parse(body);
        var root = doc.RootElement;
        var checkoutUrl = root.TryGetProperty("url", out var urlEl) ? urlEl.GetString() : null;
        var sessionId = root.TryGetProperty("id", out var idEl) ? idEl.GetString() : null;

        return new StripeCheckoutResult("stripe", checkoutUrl, sessionId);
    }

    public bool ValidateWebhookSignature(string payload, string? signatureHeader)
    {
        var webhookSecret = _configuration["Payments:Stripe:WebhookSecret"];
        if (string.IsNullOrWhiteSpace(webhookSecret))
        {
            return true;
        }

        if (string.IsNullOrWhiteSpace(signatureHeader))
        {
            return false;
        }

        var signatureParts = signatureHeader.Split(',');
        var timestampPart = signatureParts.FirstOrDefault(p => p.StartsWith("t="));
        var hashPart = signatureParts.FirstOrDefault(p => p.StartsWith("v1="));
        if (timestampPart is null || hashPart is null)
        {
            return false;
        }

        var timestamp = timestampPart[2..];
        var expected = hashPart[3..];
        var signedPayload = $"{timestamp}.{payload}";

        using var hmac = new System.Security.Cryptography.HMACSHA256(Encoding.UTF8.GetBytes(webhookSecret));
        var computedBytes = hmac.ComputeHash(Encoding.UTF8.GetBytes(signedPayload));
        var computed = BitConverter.ToString(computedBytes).Replace("-", "").ToLowerInvariant();
        return string.Equals(computed, expected, StringComparison.OrdinalIgnoreCase);
    }
}
