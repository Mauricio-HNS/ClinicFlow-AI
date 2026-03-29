using ClinicFlow.Application.Contracts;
using ClinicFlow.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace ClinicFlow.Api.Controllers;

[ApiController]
[Route("api/platform")]
public sealed class PlatformAdminController(PlatformAdminService service) : ControllerBase
{
    [HttpGet("dashboard")]
    public ActionResult<PlatformDashboardDto> GetDashboard() => Ok(service.GetDashboard());

    [HttpGet("clients")]
    public ActionResult<IReadOnlyList<PlatformClientDto>> GetClients() => Ok(service.GetClients());

    [HttpGet("messages")]
    public ActionResult<IReadOnlyList<PlatformMessageDto>> GetMessages() => Ok(service.GetMessages());

    [HttpGet("clients/{clientId:guid}/access-members")]
    public ActionResult<IReadOnlyList<PlatformAccessMemberDto>> GetAccessMembers(Guid clientId) =>
        Ok(service.GetAccessMembers(clientId));

    [HttpPost("clients/{clientId:guid}/gift-month")]
    public ActionResult<PlatformClientDto> GiftMonth(Guid clientId) => Ok(service.GiftOneMonth(clientId));

    [HttpPost("clients/{clientId:guid}/suspend")]
    public ActionResult<PlatformClientDto> Suspend(Guid clientId) => Ok(service.SuspendClient(clientId));

    [HttpPut("clients/{clientId:guid}/note")]
    public ActionResult<PlatformClientDto> UpdateNote(Guid clientId, [FromBody] UpdatePlatformClientNoteRequest request) =>
        Ok(service.UpdateNote(clientId, request));

    [HttpDelete("clients/{clientId:guid}")]
    public IActionResult Delete(Guid clientId) =>
        service.DeleteClient(clientId) ? NoContent() : NotFound();

    [HttpPost("messages")]
    public ActionResult<PlatformMessageDto> SendMessage([FromBody] SendPlatformMessageRequest request) =>
        Ok(service.SendMessage(request));

    [HttpPost("clients/{clientId:guid}/access-members")]
    public ActionResult<PlatformAccessMemberDto> AddAccessMember(Guid clientId, [FromBody] CreatePlatformAccessMemberRequest request) =>
        Ok(service.AddAccessMember(clientId, request));
}
