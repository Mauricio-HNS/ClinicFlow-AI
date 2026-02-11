class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String type;
  final String posted;
  final String description;
  final bool remote;
  final String? imageAsset;
  final String? imageUrl;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.type,
    required this.posted,
    required this.description,
    this.remote = false,
    this.imageAsset,
    this.imageUrl,
  });
}
