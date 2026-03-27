using ClinicFlow.Api.Infrastructure;
using ClinicFlow.Application.Contracts;
using ClinicFlow.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace ClinicFlow.Api.Controllers;

[ApiController]
[Route("api/dashboard")]
public sealed class DashboardController(ClinicFlowAppService service) : ControllerBase
{
    [HttpGet("summary")]
    public ActionResult<DashboardSummaryDto> GetSummary() =>
        Ok(service.GetDashboard(TenantContext.ReadTenantId(HttpContext)));
}
