class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? imageUrl;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
    );
  }
}
