import '../models/sale.dart';

class SemanticSearchResult {
  final List<Sale> sales;
  final String summary;

  const SemanticSearchResult({
    required this.sales,
    required this.summary,
  });
}

class SemanticSaleSearch {
  static const Map<String, String> _categoryByToken = {
    'notebook': 'eletronicos',
    'laptop': 'eletronicos',
    'pc': 'eletronicos',
    'computador': 'eletronicos',
    'programar': 'eletronicos',
    'tv': 'eletronicos',
    'som': 'eletronicos',
    'roupa': 'roupas',
    'moda': 'roupas',
    'cozinha': 'cozinha',
    'movel': 'moveis',
    'sofa': 'moveis',
    'mesa': 'moveis',
    'cadeira': 'moveis',
  };

  static const Set<String> _cheapTokens = {
    'barato',
    'barata',
    'economico',
    'economica',
    'baixo',
    'preco',
    'oferta',
    'promo',
  };

  static const Set<String> _nearTokens = {
    'perto',
    'proximo',
    'proxima',
    'aqui',
    'bairro',
  };

  static SemanticSearchResult searchSales(String query, List<Sale> source) {
    final normalizedQuery = _normalize(query.trim());
    if (normalizedQuery.isEmpty) {
      return const SemanticSearchResult(sales: [], summary: '');
    }

    final tokens = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    final wantsCheap = tokens.any(_cheapTokens.contains);
    final wantsNear = tokens.any(_nearTokens.contains);

    final mappedCategories = <String>{};
    for (final token in tokens) {
      final mapped = _categoryByToken[token];
      if (mapped != null) mappedCategories.add(mapped);
    }

    final scored = <({Sale sale, double score})>[];
    for (final sale in source) {
      final title = _normalize(sale.title);
      final category = _normalize(sale.category);
      double score = 0;

      if (title.contains(normalizedQuery) || category.contains(normalizedQuery)) {
        score += 9;
      }

      for (final token in tokens) {
        if (token.length < 2) continue;
        if (title.contains(token)) score += 3.2;
        if (category.contains(token)) score += 3.8;
      }

      if (mappedCategories.contains(category)) {
        score += 6.5;
      }

      if (wantsCheap) {
        final price = _extractPriceValue(sale.price);
        if (price != null) {
          score += ((160 - price) / 40).clamp(0, 4.5);
        }
      }

      if (wantsNear) {
        final km = _extractDistanceKm(sale.distance);
        if (km != null) {
          score += ((4 - km) / 1.2).clamp(0, 3.5);
        }
      }

      if (score > 0) {
        scored.add((sale: sale, score: score));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final ordered = scored.map((item) => item.sale).toList();

    final summaryParts = <String>[];
    if (mappedCategories.isNotEmpty) summaryParts.add('categoria relacionada');
    if (wantsCheap) summaryParts.add('menor preco');
    if (wantsNear) summaryParts.add('mais perto');
    if (summaryParts.isEmpty) summaryParts.add('relevancia por descricao');

    final summary = 'Busca semantica ativa: ${summaryParts.join(' + ')}';

    if (ordered.isEmpty) {
      return SemanticSearchResult(
        sales: source,
        summary: '$summary (sem match exato, mostrando sugestoes)',
      );
    }

    return SemanticSearchResult(sales: ordered, summary: summary);
  }

  static String _normalize(String input) {
    final lower = input.toLowerCase();
    return lower
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c');
  }

  static double? _extractPriceValue(String text) {
    final matches = RegExp(r'(\d+[.,]?\d*)').allMatches(text);
    if (matches.isEmpty) return null;
    final values = matches
        .map((m) => double.tryParse(m.group(1)!.replaceAll(',', '.')))
        .whereType<double>()
        .toList();
    if (values.isEmpty) return null;
    final total = values.reduce((a, b) => a + b);
    return total / values.length;
  }

  static double? _extractDistanceKm(String text) {
    final match = RegExp(r'(\d+[.,]?\d*)').firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!.replaceAll(',', '.'));
  }
}
