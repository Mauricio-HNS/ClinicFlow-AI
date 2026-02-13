namespace GarageSales.Api.Contracts;

public record ChatSellerRequest(string Prompt, decimal? BudgetMax, string? Currency, string? Locale);

public record ChatSellerResponse(
    string Answer,
    IReadOnlyList<ProductSuggestionDto> Suggestions,
    IReadOnlyList<string> FollowUpQuestions);

public record ProductSuggestionDto(
    string ProductId,
    string Title,
    decimal Price,
    string Currency,
    string Reason);

public record ListingGenerateRequest(
    string RawText,
    string? Condition,
    string? Brand,
    string? Locale);

public record ListingGenerateResponse(
    string Title,
    string Description,
    string Category,
    IReadOnlyList<string> Tags,
    decimal? SuggestedPrice,
    string? Currency);

public record SemanticSearchRequest(string Query, int Limit = 8, string? City = null, string? Category = null);

public record SemanticSearchHitDto(
    string ProductId,
    string Title,
    string Category,
    decimal Price,
    string Currency,
    double Score,
    string WhyMatched);

public record SemanticSearchResponse(
    string NormalizedIntent,
    IReadOnlyList<SemanticSearchHitDto> Hits);

public record PricingSuggestionRequest(
    string Category,
    string Condition,
    string City,
    decimal? CurrentPrice,
    string Currency,
    int ViewsLast7d,
    int SavesLast7d);

public record PricingSuggestionResponse(
    decimal SuggestedPrice,
    decimal MinRecommended,
    decimal MaxRecommended,
    string Strategy,
    string Rationale);

public record ReviewSummaryRequest(IReadOnlyList<string> Reviews, string? Locale);

public record ReviewSummaryResponse(
    string Summary,
    IReadOnlyList<string> Strengths,
    IReadOnlyList<string> Weaknesses,
    string Recommendation);
