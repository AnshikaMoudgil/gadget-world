class ProductModel {
  final String id;
  final String slug;
  final String name;
  final String? brandId;
  final String? categoryId;
  final String? description;
  final List<String> aboutPoints;
  final List<String> images;
  final double price;
  final double? mrp;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;

  ProductModel({
    required this.id,
    required this.slug,
    required this.name,
    this.brandId,
    this.categoryId,
    this.description,
    this.aboutPoints = const [],
    this.images = const [],
    required this.price,
    this.mrp,
    this.stockQuantity = 0,
    this.isActive = true,
    this.isFeatured = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      brandId: json['brand_id'] as String?,
      categoryId: json['category_id'] as String?,
      description: json['description'] as String?,
      aboutPoints: List<String>.from(json['about_points'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] as num).toDouble(),
      mrp: json['mrp'] != null ? (json['mrp'] as num).toDouble() : null,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      isFeatured: (json['is_featured'] as bool?) ?? false,
    );
  }
}
