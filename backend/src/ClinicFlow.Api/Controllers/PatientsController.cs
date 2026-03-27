using ClinicFlow.Api.Infrastructure;
using ClinicFlow.Application.Contracts;
using ClinicFlow.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace ClinicFlow.Api.Controllers;

[ApiController]
[Route("api/patients")]
public sealed class PatientsController(ClinicFlowAppService service) : ControllerBase
{
    [HttpGet]
    public ActionResult<IReadOnlyList<PatientDto>> GetAll() =>
        Ok(service.GetPatients(TenantContext.ReadTenantId(HttpContext)));

    [HttpPost]
    public ActionResult<PatientDto> Create([FromBody] CreatePatientRequest request) =>
        Ok(service.CreatePatient(TenantContext.ReadTenantId(HttpContext), request));
}
