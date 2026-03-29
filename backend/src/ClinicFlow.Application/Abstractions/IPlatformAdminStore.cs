using ClinicFlow.Application.Contracts;

namespace ClinicFlow.Application.Abstractions;

public interface IPlatformAdminStore
{
    IReadOnlyList<PlatformClientDto> GetClients();
    PlatformClientDto? FindClient(Guid clientId);
    PlatformClientDto SaveClient(PlatformClientDto client);
    bool DeleteClient(Guid clientId);
    IReadOnlyList<PlatformMessageDto> GetMessages();
    PlatformMessageDto AddMessage(PlatformMessageDto message);
    IReadOnlyList<PlatformAccessMemberDto> GetAccessMembers(Guid clientId);
    PlatformAccessMemberDto AddAccessMember(PlatformAccessMemberDto member);
}
