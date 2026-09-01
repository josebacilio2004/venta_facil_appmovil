class CategoryEntity {
  final int id;
  final String name;
  final String? description;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
  });
}
