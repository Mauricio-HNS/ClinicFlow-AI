using GarageSales.Api.Contracts;
using Microsoft.AspNetCore.Mvc;

namespace GarageSales.Api.Controllers;

[ApiController]
[Route("api/ai")]
public class AiController : ControllerBase
{
    [HttpPost("chat-seller")]
    public ActionResult<ChatSellerResponse> ChatSeller([FromBody] ChatSellerRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Prompt))
        {
            return BadRequest("Prompt is required.");
        }

        var currency = string.IsNullOrWhiteSpace(request.Currency) ? "EUR" : request.Currency!;
        var budget = request.BudgetMax ?? 500m;

        var suggestions = new List<ProductSuggestionDto>
        {
            new("prd-iphone12-128", "iPhone 12 128GB", Math.Min(budget, 499m), currency, "Camera forte e ótima liquidez de revenda."),
            new("prd-pixel7-128", "Google Pixel 7 128GB", Math.Min(budget, 469m), currency, "Fotos noturnas consistentes e Android puro."),
            new("prd-galaxy-s22", "Galaxy S22 128GB", Math.Min(budget, 489m), currency, "Bom equilíbrio entre câmera, tela e desempenho.")
        };

        var answer =
            $"Com base no seu pedido, foque em aparelhos com câmera principal forte e preço até {budget:0.##} {currency}. " +
            "Priorize bateria acima de 85% e peça teste de câmera em baixa luz antes de fechar.";

        return Ok(new ChatSellerResponse(
            answer,
            suggestions,
            new[]
            {
                "Você prefere iOS ou Android?",
                "Quer apenas produtos com garantia do vendedor?"
            }));
    }

    [HttpPost("listing/generate")]
    public ActionResult<ListingGenerateResponse> GenerateListing([FromBody] ListingGenerateRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.RawText))
        {
            return BadRequest("RawText is required.");
        }

        var category = InferCategory(request.RawText);
        var condition = string.IsNullOrWhiteSpace(request.Condition) ? "bom estado" : request.Condition!;

        var title = $"{CapitalizeFirst(request.RawText.Split(' ').First())} {condition} - pronto para uso";
        var description =
            $"{request.RawText.Trim()}. Produto em {condition}, testado e funcionando normalmente. " +
            "Entrega em mãos na cidade combinada e envio de fotos detalhadas pelo chat.";

        return Ok(new ListingGenerateResponse(
            title,
            description,
            category,
            new[] { "usado", "oportunidade", category.ToLowerInvariant().Replace(" ", "-") },
            SuggestedPriceByCategory(category),
            "EUR"));
    }

    [HttpPost("search/semantic")]
    public ActionResult<SemanticSearchResponse> SemanticSearch([FromBody] SemanticSearchRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Query))
        {
            return BadRequest("Query is required.");
        }

        var normalizedIntent = request.Query.Trim().ToLowerInvariant();
        var hits = new List<SemanticSearchHitDto>
        {
            new("prd-001", "Sofá 2 lugares compacto", "Casa e Jardim", 180m, "EUR", 0.91, "Compatível com ambientes pequenos e orçamento médio."),
            new("prd-002", "Poltrona retrô azul", "Casa e Jardim", 95m, "EUR", 0.87, "Boa relação custo-benefício para sala compacta."),
            new("prd-003", "Tapete minimalista 1.5x2m", "Casa e Jardim", 45m, "EUR", 0.79, "Complementa decoração sem ocupar muito espaço.")
        }
        .Take(Math.Clamp(request.Limit, 1, 20))
        .ToList();

        return Ok(new SemanticSearchResponse(normalizedIntent, hits));
    }

    [HttpPost("pricing/suggest")]
    public ActionResult<PricingSuggestionResponse> SuggestPrice([FromBody] PricingSuggestionRequest request)
    {
        var basePrice = request.CurrentPrice ?? BasePriceByCondition(request.Condition);
        var demandFactor = 1m;

        if (request.ViewsLast7d >= 100) demandFactor += 0.06m;
        if (request.SavesLast7d >= 20) demandFactor += 0.08m;
        if (request.SavesLast7d == 0 && request.ViewsLast7d > 50) demandFactor -= 0.07m;

        var suggested = Math.Round(basePrice * demandFactor, 2);
        var min = Math.Round(suggested * 0.92m, 2);
        var max = Math.Round(suggested * 1.08m, 2);

        return Ok(new PricingSuggestionResponse(
            suggested,
            min,
            max,
            "conversao_rapida",
            "Ajuste baseado em interesse recente (visualizações/salvos) e condição do item."));
    }

    [HttpPost("reviews/summarize")]
    public ActionResult<ReviewSummaryResponse> SummarizeReviews([FromBody] ReviewSummaryRequest request)
    {
        if (request.Reviews is null || request.Reviews.Count == 0)
        {
            return BadRequest("At least one review is required.");
        }

        return Ok(new ReviewSummaryResponse(
            "Produto bem avaliado por custo-benefício e facilidade de uso, com reclamações pontuais sobre bateria.",
            new[] { "Boa relação preço/qualidade", "Uso simples no dia a dia", "Entrega rápida" },
            new[] { "Bateria abaixo do esperado em uso intenso", "Manual pouco detalhado" },
            "Recomendado para uso moderado; para uso pesado, ofereça bateria extra ou versão superior."));
    }

    private static string InferCategory(string rawText)
    {
        var text = rawText.ToLowerInvariant();

        if (text.Contains("sofa") || text.Contains("mesa") || text.Contains("cadeira")) return "Casa e Jardim";
        if (text.Contains("iphone") || text.Contains("celular") || text.Contains("notebook")) return "Eletrônicos";
        if (text.Contains("bike") || text.Contains("bicicleta")) return "Esportes";

        return "Outros";
    }

    private static decimal SuggestedPriceByCategory(string category) => category switch
    {
        "Eletrônicos" => 320m,
        "Casa e Jardim" => 140m,
        "Esportes" => 180m,
        _ => 90m
    };

    private static decimal BasePriceByCondition(string condition)
    {
        var c = condition.Trim().ToLowerInvariant();

        if (c.Contains("novo")) return 180m;
        if (c.Contains("excelente")) return 150m;
        if (c.Contains("bom")) return 120m;

        return 90m;
    }

    private static string CapitalizeFirst(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return input;
        if (input.Length == 1) return input.ToUpperInvariant();
        return char.ToUpperInvariant(input[0]) + input[1..].ToLowerInvariant();
    }
}
