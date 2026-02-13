import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class FavoritesApiClient {
  FavoritesApiClient._();

  static final FavoritesApiClient instance = FavoritesApiClient._();
  static const _defaultPort = 5055;
  static const _connectTimeout = Duration(milliseconds: 2500);

  static String get _baseUrl {
    const fromEnv = String.fromEnvironment('APP_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://127.0.0.1:$_defaultPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_defaultPort';
    return 'http://127.0.0.1:$_defaultPort';
  }

  Future<Set<String>> fetchMine(String token) async {
    final uri = Uri.parse('$_baseUrl/api/favorites');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao carregar favoritos.' : text);
      }
      final decoded = jsonDecode(text);
      if (decoded is! List) return <String>{};
      final ids = decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => (item['listingId'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toSet();
      return ids;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> add(String token, String listingId) async {
    final uri = Uri.parse('$_baseUrl/api/favorites');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(
        utf8.encode(jsonEncode(<String, String>{'listingId': listingId})),
      );
      final response = await request.close().timeout(_connectTimeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        final text = await utf8.decodeStream(response);
        throw Exception(text.isEmpty ? 'Falha ao favoritar.' : text);
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<void> remove(String token, String listingId) async {
    final uri = Uri.parse('$_baseUrl/api/favorites/$listingId');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.deleteUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        final text = await utf8.decodeStream(response);
        throw Exception(text.isEmpty ? 'Falha ao desfavoritar.' : text);
      }
    } finally {
      client.close(force: true);
    }
  }
}
