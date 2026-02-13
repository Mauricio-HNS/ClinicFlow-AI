import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String phone;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class AuthSession {
  final String token;
  final AuthUser user;

  const AuthSession({required this.token, required this.user});
}

class AuthApiClient {
  AuthApiClient._();

  static final AuthApiClient instance = AuthApiClient._();
  static const _defaultPort = 5055;
  static const _connectTimeout = Duration(milliseconds: 2500);

  static String get _baseUrl {
    const fromEnv = String.fromEnvironment('APP_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://127.0.0.1:$_defaultPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_defaultPort';
    return 'http://127.0.0.1:$_defaultPort';
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final payload = <String, String>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
    final response = await _post('/api/auth/register', payload);
    return _parseSession(response);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final payload = <String, String>{'email': email, 'password': password};
    final response = await _post('/api/auth/login', payload);
    return _parseSession(response);
  }

  Future<AuthUser> me(String token) async {
    final uri = Uri.parse('$_baseUrl/api/auth/me');
    final client = HttpClient()..connectionTimeout = _connectTimeout;

    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao carregar perfil.' : text);
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Resposta inválida de perfil.');
      }
      return _parseUser(decoded);
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> payload,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(utf8.encode(jsonEncode(payload)));
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha na autenticação.' : text);
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Resposta inválida da API.');
      }
      return decoded;
    } on SocketException {
      throw Exception('Backend indisponível em $_baseUrl.');
    } finally {
      client.close(force: true);
    }
  }

  AuthSession _parseSession(Map<String, dynamic> payload) {
    final token = (payload['token'] ?? '').toString();
    final rawUser = payload['user'];
    if (token.isEmpty || rawUser is! Map<String, dynamic>) {
      throw Exception('Sessão inválida retornada pela API.');
    }
    return AuthSession(token: token, user: _parseUser(rawUser));
  }

  AuthUser _parseUser(Map<String, dynamic> payload) {
    return AuthUser(
      id: (payload['id'] ?? '').toString(),
      name: (payload['name'] ?? '').toString(),
      email: (payload['email'] ?? '').toString(),
      phone: (payload['phone'] ?? '').toString(),
    );
  }
}
