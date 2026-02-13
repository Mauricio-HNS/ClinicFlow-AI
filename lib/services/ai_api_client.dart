import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class RemoteSemanticHit {
  final String productId;
  final String title;
  final String category;
  final double price;
  final String currency;
  final double score;
  final String whyMatched;

  const RemoteSemanticHit({
    required this.productId,
    required this.title,
    required this.category,
    required this.price,
    required this.currency,
    required this.score,
    required this.whyMatched,
  });
}

class RemoteSemanticSearchResponse {
  final String normalizedIntent;
  final List<RemoteSemanticHit> hits;

  const RemoteSemanticSearchResponse({
    required this.normalizedIntent,
    required this.hits,
  });
}

class AiApiClient {
  AiApiClient._();

  static final AiApiClient instance = AiApiClient._();
  static const _defaultPort = 5055;
  static const _connectTimeout = Duration(milliseconds: 1800);

  static String get _baseUrl {
    const fromEnv = String.fromEnvironment('APP_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://127.0.0.1:$_defaultPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_defaultPort';
    return 'http://127.0.0.1:$_defaultPort';
  }

  Future<RemoteSemanticSearchResponse?> semanticSearch({
    required String query,
    required String city,
    int limit = 8,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/ai/search/semantic');
      final client = HttpClient()..connectionTimeout = _connectTimeout;
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(
        utf8.encode(
          jsonEncode(<String, Object>{
            'query': query,
            'limit': limit,
            'city': city,
          }),
        ),
      );

      final response = await request.close().timeout(_connectTimeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        client.close(force: true);
        return null;
      }

      final payload = await utf8.decodeStream(response);
      client.close(force: true);
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;

      final rawHits = decoded['hits'];
      if (rawHits is! List) {
        return RemoteSemanticSearchResponse(
          normalizedIntent: (decoded['normalizedIntent'] ?? '').toString(),
          hits: const <RemoteSemanticHit>[],
        );
      }

      final hits = <RemoteSemanticHit>[];
      for (final item in rawHits) {
        if (item is! Map<String, dynamic>) continue;
        hits.add(
          RemoteSemanticHit(
            productId: (item['productId'] ?? '').toString(),
            title: (item['title'] ?? '').toString(),
            category: (item['category'] ?? '').toString(),
            price: _toDouble(item['price']),
            currency: (item['currency'] ?? 'EUR').toString(),
            score: _toDouble(item['score']),
            whyMatched: (item['whyMatched'] ?? '').toString(),
          ),
        );
      }

      return RemoteSemanticSearchResponse(
        normalizedIntent: (decoded['normalizedIntent'] ?? '').toString(),
        hits: hits,
      );
    } catch (_) {
      return null;
    }
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }
}
