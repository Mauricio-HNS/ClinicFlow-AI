namespace GarageSales.Api.Contracts;

public record FavoriteUpsertRequest(string ListingId);

public record FavoriteDto(string ListingId, DateTime CreatedAtUtc);
