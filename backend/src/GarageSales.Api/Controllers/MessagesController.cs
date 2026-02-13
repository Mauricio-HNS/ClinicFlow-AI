using GarageSales.Api.Contracts;
using GarageSales.Api.Models;
using GarageSales.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace GarageSales.Api.Controllers;

[ApiController]
[Route("api/messages")]
public class MessagesController : ControllerBase
{
    private readonly MessageStore _messageStore;
    private readonly AuthTokenService _tokenService;

    public MessagesController(MessageStore messageStore, AuthTokenService tokenService)
    {
        _messageStore = messageStore;
        _tokenService = tokenService;
    }

    [HttpGet("mine")]
    public async Task<ActionResult<IReadOnlyList<MessageDto>>> Mine()
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var items = await _messageStore.GetByOwnerAsync(principal.UserId);
        return Ok(items.Select(ToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<MessageDto>> Create([FromBody] MessageCreateRequest request)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        if (string.IsNullOrWhiteSpace(request.Title) || string.IsNullOrWhiteSpace(request.Preview))
        {
            return BadRequest("Title and preview are required.");
        }

        var item = new MessageThread
        {
            Id = Guid.NewGuid().ToString("N"),
            OwnerUserId = principal.UserId,
            Title = request.Title.Trim(),
            Preview = request.Preview.Trim(),
            TimeLabel = string.IsNullOrWhiteSpace(request.TimeLabel) ? "agora" : request.TimeLabel.Trim(),
            Opened = request.Opened,
            CreatedAtUtc = DateTime.UtcNow,
            UpdatedAtUtc = DateTime.UtcNow
        };

        await _messageStore.CreateAsync(item);
        return Ok(ToDto(item));
    }

    [HttpPut("{messageId}/open")]
    public async Task<ActionResult<MessageDto>> MarkOpen(string messageId)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var updated = await _messageStore.MarkOpenedAsync(principal.UserId, messageId);
        if (updated is null)
        {
            return NotFound();
        }

        return Ok(ToDto(updated));
    }

    [HttpDelete("{messageId}")]
    public async Task<IActionResult> DeleteOne(string messageId)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var removed = await _messageStore.DeleteAsync(principal.UserId, messageId);
        if (!removed)
        {
            return NotFound();
        }

        return NoContent();
    }

    [HttpDelete("mine")]
    public async Task<IActionResult> DeleteMine()
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        await _messageStore.DeleteAllAsync(principal.UserId);
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

    private static MessageDto ToDto(MessageThread item)
    {
        return new MessageDto(
            item.Id,
            item.Title,
            item.Preview,
            item.TimeLabel,
            item.Opened,
            item.CreatedAtUtc);
    }
}
