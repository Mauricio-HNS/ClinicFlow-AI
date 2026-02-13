import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../data/categories.dart';
import '../models/sale.dart';

class ListingsApiClient {
  ListingsApiClient._();

  static final ListingsApiClient instance = ListingsApiClient._();
  static const _defaultPort = 5055;
  static const _connectTimeout = Duration(milliseconds: 2500);

  static String get _baseUrl {
    const fromEnv = String.fromEnvironment('APP_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://127.0.0.1:$_defaultPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_defaultPort';
    return 'http://127.0.0.1:$_defaultPort';
  }

  Future<List<Sale>> fetchMine(String token) async {
    final uri = Uri.parse('$_baseUrl/api/listings/mine');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao carregar anúncios.' : text);
      }

      final decoded = jsonDecode(text);
      if (decoded is! List) return const <Sale>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_toSale)
          .toList(growable: false);
    } finally {
      client.close(force: true);
    }
  }

  Future<Sale> create(String token, Sale sale) async {
    final uri = Uri.parse('$_baseUrl/api/listings');
    return _sendUpsert(uri: uri, method: 'POST', token: token, sale: sale);
  }

  Future<Sale> update(String token, Sale sale) async {
    final uri = Uri.parse('$_baseUrl/api/listings/${sale.id}');
    return _sendUpsert(uri: uri, method: 'PUT', token: token, sale: sale);
  }

  Future<void> remove(String token, String saleId) async {
    final uri = Uri.parse('$_baseUrl/api/listings/$saleId');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.deleteUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      if (response.statusCode == 404) return;
      if (response.statusCode < 200 || response.statusCode > 299) {
        final text = await utf8.decodeStream(response);
        throw Exception(text.isEmpty ? 'Falha ao remover anúncio.' : text);
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<Sale> _sendUpsert({
    required Uri uri,
    required String method,
    required String token,
    required Sale sale,
  }) async {
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final HttpClientRequest request;
      if (method == 'POST') {
        request = await client.postUrl(uri).timeout(_connectTimeout);
      } else {
        request = await client.putUrl(uri).timeout(_connectTimeout);
      }
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(
        utf8.encode(
          jsonEncode(<String, dynamic>{
            'title': sale.title,
            'category': sale.category,
            'price': sale.price,
            'distance': sale.distance,
            'date': sale.date,
            'featured': sale.featured,
            'imageAsset': sale.imageAsset,
            'imageUrl': sale.imageUrl,
            'lat': sale.lat,
            'lng': sale.lng,
            'isEvent': sale.isEvent,
            'consumeEventCredit': sale.consumeEventCredit,
            'eventPaymentId': sale.eventPaymentId,
            'photoPaths': sale.photoPaths,
          }),
        ),
      );

      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao salvar anúncio.' : text);
      }

      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Resposta inválida do backend.');
      }
      return _toSale(decoded);
    } finally {
      client.close(force: true);
    }
  }

  Sale _toSale(Map<String, dynamic> payload) {
    final category = (payload['category'] ?? 'Outros').toString();
    final categoryData = allCategories.firstWhere(
      (item) => item.label == category,
      orElse: () => allCategories.firstWhere(
        (item) => item.label == 'Outros',
        orElse: () => allCategories.first,
      ),
    );

    final rawPhotos = payload['photoPaths'];
    final photoPaths = rawPhotos is List
        ? rawPhotos.map((item) => item.toString()).toList(growable: false)
        : const <String>[];

    return Sale(
      id: (payload['id'] ?? '').toString(),
      title: (payload['title'] ?? '').toString(),
      category: category,
      price: (payload['price'] ?? '').toString(),
      distance: (payload['distance'] ?? '').toString(),
      date: (payload['date'] ?? '').toString(),
      imageAsset: payload['imageAsset']?.toString(),
      imageUrl: payload['imageUrl']?.toString(),
      color: categoryData.color,
      icon: categoryData.icon,
      lat: _toDouble(payload['lat'], 40.4168),
      lng: _toDouble(payload['lng'], -3.7038),
      featured: payload['featured'] == true,
      isEvent: payload['isEvent'] == true,
      consumeEventCredit: payload['consumeEventCredit'] == true,
      eventPaymentId: payload['eventPaymentId']?.toString(),
      photoPaths: photoPaths,
    );
  }

  double _toDouble(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}
