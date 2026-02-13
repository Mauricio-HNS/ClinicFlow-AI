import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class MessageThreadDto {
  final String id;
  final String title;
  final String preview;
  final String timeLabel;
  final bool opened;

  const MessageThreadDto({
    required this.id,
    required this.title,
    required this.preview,
    required this.timeLabel,
    required this.opened,
  });
}

class MessagesApiClient {
  MessagesApiClient._();

  static final MessagesApiClient instance = MessagesApiClient._();
  static const _defaultPort = 5055;
  static const _connectTimeout = Duration(milliseconds: 2500);

  static String get _baseUrl {
    const fromEnv = String.fromEnvironment('APP_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://127.0.0.1:$_defaultPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_defaultPort';
    return 'http://127.0.0.1:$_defaultPort';
  }

  Future<List<MessageThreadDto>> fetchMine(String token) async {
    final uri = Uri.parse('$_baseUrl/api/messages/mine');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao carregar mensagens.' : text);
      }
      final decoded = jsonDecode(text);
      if (decoded is! List) return const <MessageThreadDto>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_toDto)
          .toList(growable: false);
    } finally {
      client.close(force: true);
    }
  }

  Future<MessageThreadDto> create({
    required String token,
    required String title,
    required String preview,
    required String timeLabel,
    required bool opened,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/messages');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(
        utf8.encode(
          jsonEncode(<String, dynamic>{
            'title': title,
            'preview': preview,
            'timeLabel': timeLabel,
            'opened': opened,
          }),
        ),
      );
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao criar mensagem.' : text);
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Resposta inválida da API de mensagens.');
      }
      return _toDto(decoded);
    } finally {
      client.close(force: true);
    }
  }

  Future<void> markOpened(String token, String messageId) async {
    final uri = Uri.parse('$_baseUrl/api/messages/$messageId/open');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.putUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        final text = await utf8.decodeStream(response);
        throw Exception(text.isEmpty ? 'Falha ao marcar como lida.' : text);
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<void> remove(String token, String messageId) async {
    final uri = Uri.parse('$_baseUrl/api/messages/$messageId');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.deleteUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        final text = await utf8.decodeStream(response);
        throw Exception(text.isEmpty ? 'Falha ao remover mensagem.' : text);
      }
    } finally {
      client.close(force: true);
    }
  }

  Future<void> removeAll(String token) async {
    final uri = Uri.parse('$_baseUrl/api/messages/mine');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.deleteUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      if (response.statusCode < 200 || response.statusCode > 299) {
        final text = await utf8.decodeStream(response);
        throw Exception(text.isEmpty ? 'Falha ao remover mensagens.' : text);
      }
    } finally {
      client.close(force: true);
    }
  }

  MessageThreadDto _toDto(Map<String, dynamic> item) {
    return MessageThreadDto(
      id: (item['id'] ?? '').toString(),
      title: (item['title'] ?? '').toString(),
      preview: (item['preview'] ?? '').toString(),
      timeLabel: (item['timeLabel'] ?? '').toString(),
      opened: item['opened'] == true,
    );
  }
}
