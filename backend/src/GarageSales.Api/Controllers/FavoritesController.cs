using GarageSales.Api.Contracts;
using GarageSales.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace GarageSales.Api.Controllers;

[ApiController]
[Route("api/favorites")]
public class FavoritesController : ControllerBase
{
    private readonly FavoriteStore _favoriteStore;
    private readonly AuthTokenService _tokenService;

    public FavoritesController(FavoriteStore favoriteStore, AuthTokenService tokenService)
    {
        _favoriteStore = favoriteStore;
        _tokenService = tokenService;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<FavoriteDto>>> List()
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var items = await _favoriteStore.GetByOwnerAsync(principal.UserId);
        var response = items.Select(item => new FavoriteDto(item.ListingId, item.CreatedAtUtc)).ToList();
        return Ok(response);
    }

    [HttpPost]
    public async Task<IActionResult> Add([FromBody] FavoriteUpsertRequest request)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        if (string.IsNullOrWhiteSpace(request.ListingId))
        {
            return BadRequest("ListingId is required.");
        }

        await _favoriteStore.AddAsync(principal.UserId, request.ListingId.Trim());
        return NoContent();
    }

    [HttpDelete("{listingId}")]
    public async Task<IActionResult> Remove(string listingId)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        await _favoriteStore.RemoveAsync(principal.UserId, listingId.Trim());
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
}
