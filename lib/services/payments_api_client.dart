import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class EventCheckoutResult {
  final String paymentId;
  final String status;
  final String provider;
  final double amount;
  final String currency;
  final String? checkoutUrl;

  const EventCheckoutResult({
    required this.paymentId,
    required this.status,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.checkoutUrl,
  });
}

class PaymentRecordResult {
  final String id;
  final String status;
  final String provider;
  final double amount;
  final String currency;

  const PaymentRecordResult({
    required this.id,
    required this.status,
    required this.provider,
    required this.amount,
    required this.currency,
  });
}

class PaymentsApiClient {
  PaymentsApiClient._();

  static final PaymentsApiClient instance = PaymentsApiClient._();
  static const _defaultPort = 5055;
  static const _connectTimeout = Duration(milliseconds: 2500);

  static String get _baseUrl {
    const fromEnv = String.fromEnvironment('APP_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://127.0.0.1:$_defaultPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_defaultPort';
    return 'http://127.0.0.1:$_defaultPort';
  }

  Future<EventCheckoutResult> createEventCheckout(
    String token, {
    String currency = 'EUR',
  }) async {
    final uri = Uri.parse('$_baseUrl/api/payments/event/checkout');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(
        utf8.encode(jsonEncode(<String, String>{'currency': currency})),
      );
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao iniciar pagamento.' : text);
      }
      final payload = jsonDecode(text);
      if (payload is! Map<String, dynamic>) {
        throw Exception('Resposta inválida do backend de pagamentos.');
      }
      return EventCheckoutResult(
        paymentId: (payload['paymentId'] ?? '').toString(),
        status: (payload['status'] ?? '').toString(),
        provider: (payload['provider'] ?? '').toString(),
        amount: (payload['amount'] is num)
            ? (payload['amount'] as num).toDouble()
            : 0,
        currency: (payload['currency'] ?? 'EUR').toString(),
        checkoutUrl: payload['checkoutUrl']?.toString(),
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<void> confirmMock(String token, String paymentId) async {
    final uri = Uri.parse('$_baseUrl/api/payments/confirm/$paymentId');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        final text = await utf8.decodeStream(response);
        throw Exception(text.isEmpty ? 'Falha ao confirmar pagamento.' : text);
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<List<PaymentRecordResult>> fetchMine(String token) async {
    final uri = Uri.parse('$_baseUrl/api/payments/mine');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao carregar pagamentos.' : text);
      }
      final payload = jsonDecode(text);
      if (payload is! List) return const <PaymentRecordResult>[];
      return payload
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => PaymentRecordResult(
              id: (item['id'] ?? '').toString(),
              status: (item['status'] ?? '').toString(),
              provider: (item['provider'] ?? '').toString(),
              amount: (item['amount'] is num)
                  ? (item['amount'] as num).toDouble()
                  : 0,
              currency: (item['currency'] ?? 'EUR').toString(),
            ),
          )
          .toList(growable: false);
    } finally {
      client.close(force: true);
    }
  }
}
