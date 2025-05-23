class Category {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final bool isDeleted;
  final DateTime? trashDate;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.isDeleted,
    this.trashDate,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['createdBy'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      trashDate: json['trashDate'] != null ? DateTime.parse(json['trashDate']) : null,
    );
  }
}
