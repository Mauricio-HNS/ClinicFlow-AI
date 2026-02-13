using System.Text.Json;
using GarageSales.Api.Contracts;
using GarageSales.Api.Models;
using GarageSales.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace GarageSales.Api.Controllers;

[ApiController]
[Route("api/payments")]
public class PaymentsController : ControllerBase
{
    private readonly PaymentStore _paymentStore;
    private readonly StripeCheckoutService _stripeService;
    private readonly AuthTokenService _tokenService;

    public PaymentsController(
        PaymentStore paymentStore,
        StripeCheckoutService stripeService,
        AuthTokenService tokenService)
    {
        _paymentStore = paymentStore;
        _stripeService = stripeService;
        _tokenService = tokenService;
    }

    [HttpPost("event/checkout")]
    public async Task<ActionResult<PaymentCheckoutResponse>> CreateEventCheckout([FromBody] EventCheckoutRequest request)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var currency = string.IsNullOrWhiteSpace(request.Currency) ? "EUR" : request.Currency.Trim().ToUpperInvariant();
        var payment = new PaymentRecord
        {
            Id = Guid.NewGuid().ToString("N"),
            OwnerUserId = principal.UserId,
            Status = "pending",
            Provider = _stripeService.ResolveProvider(),
            Amount = 3m,
            Currency = currency,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        await _paymentStore.CreateAsync(payment);

        var checkout = await _stripeService.CreateCheckoutAsync(
            payment.Id,
            principal.UserId,
            payment.Amount,
            payment.Currency,
            request.SuccessUrl,
            request.CancelUrl);

        payment.ProviderReference = checkout.ProviderReference;
        await _paymentStore.SetProviderReferenceAsync(payment.Id, checkout.ProviderReference);

        return Ok(new PaymentCheckoutResponse(
            payment.Id,
            payment.Status,
            checkout.Provider,
            payment.Amount,
            payment.Currency,
            checkout.CheckoutUrl,
            checkout.ProviderReference));
    }

    [HttpGet("mine")]
    public async Task<ActionResult<IReadOnlyList<PaymentRecordDto>>> Mine()
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var items = await _paymentStore.GetByOwnerAsync(principal.UserId);
        return Ok(items.Select(ToDto).ToList());
    }

    [HttpGet("{paymentId}")]
    public async Task<ActionResult<PaymentRecordDto>> GetOne(string paymentId)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var item = await _paymentStore.FindByIdAsync(paymentId);
        if (item is null || item.OwnerUserId != principal.UserId)
        {
            return NotFound();
        }

        return Ok(ToDto(item));
    }

    [HttpPost("confirm/{paymentId}")]
    public async Task<ActionResult<PaymentRecordDto>> ConfirmMock(string paymentId)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var item = await _paymentStore.FindByIdAsync(paymentId);
        if (item is null || item.OwnerUserId != principal.UserId)
        {
            return NotFound();
        }

        var updated = await _paymentStore.MarkPaidAsync(item.Id);
        if (updated is null)
        {
            return NotFound();
        }

        return Ok(ToDto(updated));
    }

    [HttpPost("webhook/stripe")]
    public async Task<IActionResult> StripeWebhook()
    {
        using var reader = new StreamReader(Request.Body);
        var payload = await reader.ReadToEndAsync();
        var signatureHeader = Request.Headers["Stripe-Signature"].FirstOrDefault();
        if (!_stripeService.ValidateWebhookSignature(payload, signatureHeader))
        {
            return Unauthorized();
        }

        try
        {
            using var doc = JsonDocument.Parse(payload);
            var root = doc.RootElement;
            var eventType = root.TryGetProperty("type", out var t) ? t.GetString() : null;
            var dataObj = root.GetProperty("data").GetProperty("object");

            if (eventType == "checkout.session.completed")
            {
                string? paymentId = null;
                if (dataObj.TryGetProperty("client_reference_id", out var refEl))
                {
                    paymentId = refEl.GetString();
                }

                if (string.IsNullOrWhiteSpace(paymentId) &&
                    dataObj.TryGetProperty("metadata", out var metadataEl) &&
                    metadataEl.TryGetProperty("payment_id", out var paymentEl))
                {
                    paymentId = paymentEl.GetString();
                }

                if (!string.IsNullOrWhiteSpace(paymentId))
                {
                    await _paymentStore.MarkPaidAsync(paymentId);
                }
            }
        }
        catch
        {
            return BadRequest();
        }

        return Ok();
    }

    private AuthPrincipal? ResolvePrincipalFromRequest()
    {
        var authHeader = Request.Headers.Authorization.FirstOrDefault();
        if (string.IsNullOrWhiteSpace(authHeader) || !authHeader.StartsWith("Bearer "))
        {
            return null;
        }
        var token = authHeader["Bearer ".Length..].Trim();
        return _tokenService.ValidateToken(token);
    }

    private static PaymentRecordDto ToDto(PaymentRecord item)
    {
        return new PaymentRecordDto(
            item.Id,
            item.Status,
            item.Provider,
            item.Amount,
            item.Currency,
            item.ProviderReference,
            item.CreatedAtUtc,
            item.UpdatedAtUtc);
    }
}
