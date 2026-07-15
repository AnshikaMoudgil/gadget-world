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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
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
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      if (brandId != null) 'brand_id': brandId,
      if (categoryId != null) 'category_id': categoryId,
      if (description != null) 'description': description,
      'about_points': aboutPoints,
      'images': images,
      'price': price,
      if (mrp != null) 'mrp': mrp,
      'stock_quantity': stockQuantity,
      'is_active': isActive,
      'is_featured': isFeatured,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
