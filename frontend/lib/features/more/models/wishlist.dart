import 'package:gadget_world/features/products/models/product_model.dart';

class WishlistItem {
  final String id;
  final String wishlistId;
  final String productId;
  final String? variantId;
  final String? note;
  final DateTime addedAt;

  // Joined data
  final ProductModel? product;
  final ProductVariant? variant;

  const WishlistItem({
    required this.id,
    required this.wishlistId,
    required this.productId,
    this.variantId,
    this.note,
    required this.addedAt,
    this.product,
    this.variant,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    ProductModel? parsedProduct;
    if (json['products'] != null) {
      parsedProduct = ProductModel.fromJson(json['products']);
    }

    ProductVariant? parsedVariant;
    if (json['product_variants'] != null) {
      parsedVariant = ProductVariant.fromJson(json['product_variants']);
    }

    return WishlistItem(
      id: json['id'] as String? ?? '',
      wishlistId: json['wishlist_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      variantId: json['variant_id'] as String?,
      note: json['note'] as String?,
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'])
          : DateTime.now(),
      product: parsedProduct,
      variant: parsedVariant,
    );
  }
}
