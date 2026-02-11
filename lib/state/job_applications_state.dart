import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../models/job_application.dart';

class JobApplicationsState {
  static final ValueNotifier<List<JobApplication>> items = ValueNotifier<List<JobApplication>>([]);

  static void addApplication({
    required Job job,
    required String candidateName,
    required String candidatePhone,
    String? message,
  }) {
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
}
