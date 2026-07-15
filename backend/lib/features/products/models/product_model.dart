class ProductModel {
  final String id;
  final String slug;
  final String name;
  final String? brandId;
  final String? brandName;
  final String? categoryId;
  final String? categoryName;
  final String? description;
  final List<String> aboutPoints;
  final List<String> images;
  final double price;
  final double? mrp;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;
  final List<Map<String, dynamic>> specs;
  final List<Map<String, dynamic>> features;
  final List<Map<String, dynamic>> variants;

  ProductModel({
    required this.id,
    required this.slug,
    required this.name,
    this.brandId,
    this.brandName,
    this.categoryId,
    this.categoryName,
    this.description,
    this.aboutPoints = const [],
    this.images = const [],
    required this.price,
    this.mrp,
    this.stockQuantity = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.specs = const [],
    this.features = const [],
    this.variants = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      brandId: json['brand_id'] as String?,
      brandName: _nestedName(json['brands']) ?? json['brand_name'] as String?,
      categoryId: json['category_id'] as String?,
      categoryName:
          _nestedName(json['categories']) ?? json['category_name'] as String?,
      description: json['description'] as String?,
      aboutPoints: _strings(json['about_points']),
      images: _strings(json['images']),
      price: (json['price'] as num).toDouble(),
      mrp: json['mrp'] != null ? (json['mrp'] as num).toDouble() : null,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      isActive: (json['is_active'] as bool?) ?? true,
      isFeatured: (json['is_featured'] as bool?) ?? false,
      specs: _maps(json['product_specs'] ?? json['specs']),
      features: _maps(json['product_features'] ?? json['features']),
      variants: _maps(json['product_variants'] ?? json['variants']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        if (brandId != null) 'brand_id': brandId,
        if (brandName != null) 'brand_name': brandName,
        if (categoryId != null) 'category_id': categoryId,
        if (categoryName != null) 'category_name': categoryName,
        if (description != null) 'description': description,
        'about_points': aboutPoints,
        'images': images,
        'price': price,
        if (mrp != null) 'mrp': mrp,
        'stock_quantity': stockQuantity,
        'is_active': isActive,
        'is_featured': isFeatured,
        'specs': specs,
        'features': features,
        'variants': variants,
      };
}

List<String> _strings(Object? value) =>
    value is List ? value.whereType<String>().toList() : const [];

List<Map<String, dynamic>> _maps(Object? value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];
String? _nestedName(Object? value) {
  if (value is Map) return value['name'] as String?;
  if (value is List && value.isNotEmpty && value.first is Map) {
    return (value.first as Map)['name'] as String?;
  }
  return null;
}
