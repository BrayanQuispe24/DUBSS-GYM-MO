class DisciplineModel {
  final String id;
  final String title;
  final String category;
  final String categoryLabel;
  final String description;
  final String schedule;
  final String instructor;
  final String capacity;
  final String imageUrl;
  final List<String> tags;
  final String studentPrice;
  final String docentPrice;

  const DisciplineModel({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryLabel,
    required this.description,
    required this.schedule,
    required this.instructor,
    required this.capacity,
    required this.imageUrl,
    required this.tags,
    required this.studentPrice,
    required this.docentPrice,
  });

  factory DisciplineModel.fromJson(Map<String, dynamic> json) {
    return DisciplineModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryLabel: json['categoryLabel'] as String? ?? '',
      description: json['description'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      capacity: json['capacity'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      studentPrice: json['studentPrice'] as String? ?? '',
      docentPrice: json['docentPrice'] as String? ?? '',
    );
  }
}
