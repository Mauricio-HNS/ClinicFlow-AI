import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/job.dart';
import '../models/job_application.dart';

class JobApplicationsApiClient {
  JobApplicationsApiClient._();

  static final JobApplicationsApiClient instance = JobApplicationsApiClient._();
  static const _defaultPort = 5055;
  static const _connectTimeout = Duration(milliseconds: 2500);

  static String get _baseUrl {
    const fromEnv = String.fromEnvironment('APP_API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://127.0.0.1:$_defaultPort';
    if (Platform.isAndroid) return 'http://10.0.2.2:$_defaultPort';
    return 'http://127.0.0.1:$_defaultPort';
  }

  Future<List<JobApplication>> fetchMine(String token) async {
    final uri = Uri.parse('$_baseUrl/api/job-applications/mine');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.getUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(
          text.isEmpty ? 'Falha ao carregar candidaturas.' : text,
        );
      }
      final decoded = jsonDecode(text);
      if (decoded is! List) return const <JobApplication>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_toApplication)
          .toList(growable: false);
    } finally {
      client.close(force: true);
    }
  }

  Future<JobApplication> create({
    required String token,
    required Job job,
    required String candidateName,
    required String candidatePhone,
    String? message,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/job-applications');
    final client = HttpClient()..connectionTimeout = _connectTimeout;
    try {
      final request = await client.postUrl(uri).timeout(_connectTimeout);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.add(
        utf8.encode(
          jsonEncode(<String, dynamic>{
            'jobId': job.id,
            'jobTitle': job.title,
            'company': job.company,
            'candidateName': candidateName,
            'candidatePhone': candidatePhone,
            'message': message,
          }),
        ),
      );
      final response = await request.close().timeout(_connectTimeout);
      final text = await utf8.decodeStream(response);
      if (response.statusCode < 200 || response.statusCode > 299) {
        throw Exception(text.isEmpty ? 'Falha ao enviar candidatura.' : text);
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Resposta inválida da API de candidaturas.');
      }
      return _toApplication(decoded);
    } finally {
      client.close(force: true);
    }
  }

  JobApplication _toApplication(Map<String, dynamic> item) {
    return JobApplication(
      id: (item['id'] ?? '').toString(),
      jobId: (item['jobId'] ?? '').toString(),
      jobTitle: (item['jobTitle'] ?? '').toString(),
      company: (item['company'] ?? '').toString(),
      candidateName: (item['candidateName'] ?? '').toString(),
      candidatePhone: (item['candidatePhone'] ?? '').toString(),
      message: item['message']?.toString(),
      createdAt:
          DateTime.tryParse((item['createdAtUtc'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}
