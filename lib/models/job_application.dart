class JobApplication {
  final String id;
  final String jobId;
  final String jobTitle;
  final String company;
  final String candidateName;
  final String candidatePhone;
  final String? message;
  final DateTime createdAt;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.candidateName,
    required this.candidatePhone,
    this.message,
    required this.createdAt,
  });
}
