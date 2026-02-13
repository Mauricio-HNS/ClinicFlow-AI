using GarageSales.Api.Contracts;
using GarageSales.Api.Models;
using GarageSales.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace GarageSales.Api.Controllers;

[ApiController]
[Route("api/job-applications")]
public class JobApplicationsController : ControllerBase
{
    private readonly JobApplicationStore _store;
    private readonly AuthTokenService _tokenService;

    public JobApplicationsController(JobApplicationStore store, AuthTokenService tokenService)
    {
        _store = store;
        _tokenService = tokenService;
    }

    [HttpGet("mine")]
    public async Task<ActionResult<IReadOnlyList<JobApplicationDto>>> Mine()
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        var items = await _store.GetByOwnerAsync(principal.UserId);
        return Ok(items.Select(ToDto).ToList());
    }

    [HttpPost]
    public async Task<ActionResult<JobApplicationDto>> Create([FromBody] JobApplicationCreateRequest request)
    {
        var principal = ResolvePrincipalFromRequest();
        if (principal is null)
        {
            return Unauthorized();
        }

        if (string.IsNullOrWhiteSpace(request.JobId) ||
            string.IsNullOrWhiteSpace(request.JobTitle) ||
            string.IsNullOrWhiteSpace(request.Company) ||
            string.IsNullOrWhiteSpace(request.CandidateName) ||
            string.IsNullOrWhiteSpace(request.CandidatePhone))
        {
            return BadRequest("Missing required fields.");
        }

        var item = new JobApplicationItem
        {
            Id = Guid.NewGuid().ToString("N"),
            OwnerUserId = principal.UserId,
            JobId = request.JobId.Trim(),
            JobTitle = request.JobTitle.Trim(),
            Company = request.Company.Trim(),
            CandidateName = request.CandidateName.Trim(),
            CandidatePhone = request.CandidatePhone.Trim(),
            Message = string.IsNullOrWhiteSpace(request.Message) ? null : request.Message.Trim(),
            CreatedAtUtc = DateTime.UtcNow
        };

        await _store.CreateAsync(item);
        return Ok(ToDto(item));
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

    private static JobApplicationDto ToDto(JobApplicationItem item)
    {
        return new JobApplicationDto(
            item.Id,
            item.JobId,
            item.JobTitle,
            item.Company,
            item.CandidateName,
            item.CandidatePhone,
            item.Message,
            item.CreatedAtUtc);
    }
}
