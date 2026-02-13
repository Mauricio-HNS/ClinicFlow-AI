namespace GarageSales.Api.Contracts;

public record MessageCreateRequest(
    string Title,
    string Preview,
    string TimeLabel,
    bool Opened);

public record MessageDto(
    string Id,
    string Title,
    string Preview,
    string TimeLabel,
    bool Opened,
    DateTime CreatedAtUtc);
