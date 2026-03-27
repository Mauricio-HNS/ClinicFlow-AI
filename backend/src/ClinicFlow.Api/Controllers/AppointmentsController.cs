using ClinicFlow.Api.Infrastructure;
using ClinicFlow.Application.Contracts;
using ClinicFlow.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace ClinicFlow.Api.Controllers;

[ApiController]
[Route("api/appointments")]
public sealed class AppointmentsController(ClinicFlowAppService service) : ControllerBase
{
    [HttpGet]
    public ActionResult<IReadOnlyList<AppointmentDto>> GetAll() =>
        Ok(service.GetAppointments(TenantContext.ReadTenantId(HttpContext)));

    [HttpPost]
    public ActionResult<AppointmentDto> Create([FromBody] CreateAppointmentRequest request) =>
        Ok(service.CreateAppointment(TenantContext.ReadTenantId(HttpContext), request));

    [HttpPut("{appointmentId:guid}/status")]
    public ActionResult<AppointmentDto> UpdateStatus(Guid appointmentId, [FromBody] UpdateAppointmentStatusRequest request) =>
        Ok(service.UpdateAppointmentStatus(TenantContext.ReadTenantId(HttpContext), appointmentId, request));
}
