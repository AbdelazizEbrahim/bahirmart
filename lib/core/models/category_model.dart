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
}