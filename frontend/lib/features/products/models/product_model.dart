class ProductSpec {
  final String key;
  final String value;

  const ProductSpec({required this.key, required this.value});

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    return ProductSpec(
      key: json['spec_key'] as String? ?? json['key'] as String? ?? '',
      value: json['spec_value'] as String? ?? json['value'] as String? ?? '',
    );
  }
}

class ProductFeature {
  final String type;
  final String title;
  final String description;
  final String icon;

  const ProductFeature({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });

  factory ProductFeature.fromJson(Map<String, dynamic> json) {
    return ProductFeature(
      type: json['type'] as String? ?? 'highlight',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'check_circle_outline',
    );
  }
}

class ProductVariant {
  final String id;
  final String name;
  final double? price;
  final List<String> images;
  final int stockQuantity;

  const ProductVariant({
    required this.id,
    required this.name,
    this.price,
    this.images = const [],
    this.stockQuantity = 0,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String? ?? '',
      name: json['variant_name'] as String? ?? json['name'] as String? ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      images: _stringList(json['images']),
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

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
  final List<ProductSpec> specs;
  final List<ProductFeature> features;
  final List<ProductVariant> variants;

  const ProductModel({
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

  String? get imageUrl => images.isEmpty ? null : images.first;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final brand = _nestedMap(json['brands']);
    final category = _nestedMap(json['categories']);

    return ProductModel(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed product',
      brandId: json['brand_id'] as String?,
      brandName: brand?['name'] as String? ?? json['brand_name'] as String?,
      categoryId: json['category_id'] as String?,
      categoryName:
          category?['name'] as String? ?? json['category_name'] as String?,
      description: json['description'] as String?,
      aboutPoints: _stringList(json['about_points']),
      images: _stringList(json['images']),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      mrp: json['mrp'] != null ? (json['mrp'] as num).toDouble() : null,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      specs: _mapList(
        json['product_specs'] ?? json['specs'],
      ).map(ProductSpec.fromJson).toList(),
      features: _mapList(
        json['product_features'] ?? json['features'],
      ).map(ProductFeature.fromJson).toList(),
      variants: _mapList(
        json['product_variants'] ?? json['variants'],
      ).map(ProductVariant.fromJson).toList(),
    );
  }
}

Map<String, dynamic>? _nestedMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is List && value.isNotEmpty && value.first is Map) {
    return Map<String, dynamic>.from(value.first as Map);
  }
  return null;
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<String> _stringList(Object? value) {
  if (value == null) return const [];
  if (value is List) {
    return value
        .map((e) => e?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }
  if (value is String) {
    final str = value.trim();
    if (str.isEmpty) return const [];
    if (str.startsWith('{') && str.endsWith('}')) {
      final inner = str.substring(1, str.length - 1);
      if (inner.isEmpty) return const [];
      return inner
          .split(',')
          .map((e) => e.trim().replaceAll('"', ''))
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [str];
  }
  return const [];
}
