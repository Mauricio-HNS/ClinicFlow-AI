import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../models/job_application.dart';
import '../services/job_applications_api_client.dart';
import 'auth_session_state.dart';

class JobApplicationsState {
  static final ValueNotifier<List<JobApplication>> items =
      ValueNotifier<List<JobApplication>>([]);

  static Future<void> addApplication({
    required Job job,
    required String candidateName,
    required String candidatePhone,
    String? message,
  }) async {
    final token = AuthSessionState.token.value;
    if (token != null && token.isNotEmpty) {
      try {
        final created = await JobApplicationsApiClient.instance.create(
          token: token,
          job: job,
          candidateName: candidateName,
          candidatePhone: candidatePhone,
          message: message?.trim().isEmpty == true ? null : message?.trim(),
        );
        items.value = [created, ...items.value];
        return;
      } catch (_) {
        // Fall back to local mode.
      }
    }

    final application = JobApplication(
      id: 'app_${DateTime.now().microsecondsSinceEpoch}',
      jobId: job.id,
      jobTitle: job.title,
      company: job.company,
      candidateName: candidateName,
      candidatePhone: candidatePhone,
      message: message?.trim().isEmpty == true ? null : message?.trim(),
      createdAt: DateTime.now(),
    );
    items.value = [application, ...items.value];
  }

  static Future<void> syncMine() async {
    final token = AuthSessionState.token.value;
    if (token == null || token.isEmpty) return;
    try {
      items.value = await JobApplicationsApiClient.instance.fetchMine(token);
    } catch (_) {
      // Keep local values on failures.
    }
  }
}
