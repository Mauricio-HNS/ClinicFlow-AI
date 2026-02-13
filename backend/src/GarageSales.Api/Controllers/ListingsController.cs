using GarageSales.Api.Contracts;
using GarageSales.Api.Models;
using GarageSales.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace GarageSales.Api.Controllers;

[ApiController]
[Route("api/listings")]
public class ListingsController : ControllerBase
{
    private readonly ListingStore _listingStore;
    private readonly PaymentStore _paymentStore;
    private readonly AuthTokenService _tokenService;

    public ListingsController(
        ListingStore listingStore,
        PaymentStore paymentStore,
        AuthTokenService tokenService)
    {
        _listingStore = listingStore;
        _paymentStore = paymentStore;
        _tokenService = tokenService;
    }

    [HttpGet("mine")]
    public async Task<ActionResult<IReadOnlyList<ListingDto>>> Mine()
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var listings = await _listingStore.GetByOwnerAsync(principal.UserId);
        return Ok(listings.Select(ToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<ListingDto>> Create([FromBody] ListingUpsertRequest request)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        if (!ValidateRequest(request, out var error))
        {
            return BadRequest(error);
        }
        var paymentError = await ValidateEventPaymentAsync(principal.UserId, request);
        if (paymentError is not null)
        {
            return BadRequest(paymentError);
        }

        var listing = new ListingItem
        {
            Id = Guid.NewGuid().ToString("N"),
            OwnerUserId = principal.UserId,
            Title = request.Title.Trim(),
            Category = request.Category.Trim(),
            Price = request.Price.Trim(),
            Distance = request.Distance.Trim(),
            Date = request.Date.Trim(),
            Featured = request.Featured,
            IsEvent = request.IsEvent,
            ConsumeEventCredit = request.ConsumeEventCredit,
            EventPaymentId = request.EventPaymentId?.Trim(),
            ImageAsset = request.ImageAsset,
            ImageUrl = request.ImageUrl,
            Lat = request.Lat,
            Lng = request.Lng,
            PhotoPaths = request.PhotoPaths?.ToList() ?? new List<string>(),
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        await _listingStore.CreateAsync(listing);
        return Ok(ToDto(listing));
    }

    [HttpPut("{listingId}")]
    public async Task<ActionResult<ListingDto>> Update(string listingId, [FromBody] ListingUpsertRequest request)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        if (!ValidateRequest(request, out var error))
        {
            return BadRequest(error);
        }
        var paymentError = await ValidateEventPaymentAsync(principal.UserId, request);
        if (paymentError is not null)
        {
            return BadRequest(paymentError);
        }

        var updated = await _listingStore.UpdateAsync(principal.UserId, listingId, item =>
        {
            item.Title = request.Title.Trim();
            item.Category = request.Category.Trim();
            item.Price = request.Price.Trim();
            item.Distance = request.Distance.Trim();
            item.Date = request.Date.Trim();
            item.Featured = request.Featured;
            item.IsEvent = request.IsEvent;
            item.ConsumeEventCredit = request.ConsumeEventCredit;
            item.EventPaymentId = request.EventPaymentId?.Trim();
            item.ImageAsset = request.ImageAsset;
            item.ImageUrl = request.ImageUrl;
            item.Lat = request.Lat;
            item.Lng = request.Lng;
            item.PhotoPaths = request.PhotoPaths?.ToList() ?? new List<string>();
        });

        if (updated is null)
        {
            return NotFound();
        }

        return Ok(ToDto(updated));
    }

    [HttpDelete("{listingId}")]
    public async Task<IActionResult> Delete(string listingId)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var removed = await _listingStore.DeleteAsync(principal.UserId, listingId);
        if (!removed)
        {
            return NotFound();
        }

        return NoContent();
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

    private static bool ValidateRequest(ListingUpsertRequest request, out string error)
    {
        if (string.IsNullOrWhiteSpace(request.Title))
        {
            error = "Title is required.";
            return false;
        }

        if (string.IsNullOrWhiteSpace(request.Category))
        {
            error = "Category is required.";
            return false;
        }

        if (string.IsNullOrWhiteSpace(request.Price))
        {
            error = "Price is required.";
            return false;
        }

        error = string.Empty;
        return true;
    }

    private async Task<string?> ValidateEventPaymentAsync(
        string userId,
        ListingUpsertRequest request)
    {
        if (!request.IsEvent || request.ConsumeEventCredit)
        {
            return null;
        }

        if (string.IsNullOrWhiteSpace(request.EventPaymentId))
        {
            return "Event payment is required.";
        }

        var payment = await _paymentStore.FindByIdAsync(request.EventPaymentId.Trim());
        if (payment is null || payment.OwnerUserId != userId)
        {
            return "Payment not found.";
        }
        if (!string.Equals(payment.Status, "paid", StringComparison.OrdinalIgnoreCase))
        {
            return "Payment is not confirmed.";
        }

        return null;
    }

    private static ListingDto ToDto(ListingItem item)
    {
        return new ListingDto(
            item.Id,
            item.Title,
            item.Category,
            item.Price,
            item.Distance,
            item.Date,
            item.Featured,
            item.IsEvent,
            item.ConsumeEventCredit,
            item.EventPaymentId,
            item.ImageAsset,
            item.ImageUrl,
            item.Lat,
            item.Lng,
            item.PhotoPaths);
    }
}
