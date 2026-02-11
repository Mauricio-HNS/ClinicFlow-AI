class Job {
  final String id;
  final String title;
  final String company;
  final String companyPhone;
  final String location;
  final String salary;
  final String type;
  final String posted;
  final DateTime? publishedAt;
  final String description;
  final bool remote;
  final String? imageAsset;
  final String? imageUrl;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.companyPhone,
    required this.location,
    required this.salary,
    required this.type,
    required this.posted,
    this.publishedAt,
    required this.description,
    this.remote = false,
    this.imageAsset,
    this.imageUrl,
  });

  String relativePosted([DateTime? now]) {
    final date = publishedAt;
    if (date == null) return posted;

    final current = now ?? DateTime.now();
    final currentDate = DateTime(current.year, current.month, current.day);
    final publishedDate = DateTime(date.year, date.month, date.day);
    final days = currentDate.difference(publishedDate).inDays;

    if (days <= 0) return 'Hoje';
    if (days == 1) return 'Ontem';
    return '$days dias';
  }
}
