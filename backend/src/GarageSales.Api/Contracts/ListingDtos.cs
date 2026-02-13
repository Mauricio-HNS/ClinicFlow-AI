namespace GarageSales.Api.Contracts;

public record ListingUpsertRequest(
    string Title,
    string Category,
    string Price,
    string Distance,
    string Date,
    bool Featured,
    bool IsEvent,
    bool ConsumeEventCredit,
    string? EventPaymentId,
    string? ImageAsset,
    string? ImageUrl,
    double Lat,
    double Lng,
    IReadOnlyList<string>? PhotoPaths);

public record ListingDto(
    string Id,
    string Title,
    string Category,
    string Price,
    string Distance,
    string Date,
    bool Featured,
    bool IsEvent,
    bool ConsumeEventCredit,
    string? EventPaymentId,
    string? ImageAsset,
    string? ImageUrl,
    double Lat,
    double Lng,
    IReadOnlyList<string> PhotoPaths);
