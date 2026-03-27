using ClinicFlow.Api.Infrastructure;
using ClinicFlow.Application.Contracts;
using ClinicFlow.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace ClinicFlow.Api.Controllers;

[ApiController]
[Route("api/professionals")]
public sealed class ProfessionalsController(ClinicFlowAppService service) : ControllerBase
{
    [HttpGet]
    public ActionResult<IReadOnlyList<ProfessionalDto>> GetAll() =>
        Ok(service.GetProfessionals(TenantContext.ReadTenantId(HttpContext)));

    [HttpPost]
    public ActionResult<ProfessionalDto> Create([FromBody] CreateProfessionalRequest request) =>
        Ok(service.CreateProfessional(TenantContext.ReadTenantId(HttpContext), request));
}
