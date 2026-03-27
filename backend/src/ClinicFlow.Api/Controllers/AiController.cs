using ClinicFlow.Api.Infrastructure;
using ClinicFlow.Application.Contracts;
using ClinicFlow.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace ClinicFlow.Api.Controllers;

[ApiController]
[Route("api/ai")]
public sealed class AiController(ClinicFlowAppService service) : ControllerBase
{
    [HttpPost("patient-summary/{patientId:guid}")]
    public ActionResult<PatientSummaryDto> PatientSummary(Guid patientId) =>
        Ok(service.GeneratePatientSummary(TenantContext.ReadTenantId(HttpContext), patientId));

    [HttpPost("message-generate/{appointmentId:guid}")]
    public ActionResult<MessageSuggestionDto> MessageGenerate(Guid appointmentId) =>
        Ok(service.GenerateConfirmationMessage(TenantContext.ReadTenantId(HttpContext), appointmentId));
}
