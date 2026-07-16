class CartItem {
  final String id;
  final String cartId;
  final String productId;
  final String? variantId;
  final int quantity;

  // We can include product/variant details if fetched with joins
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? variant;

  CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    this.variantId,
    required this.quantity,
    this.product,
    this.variant,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      cartId: json['cart_id'] as String,
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      quantity: json['quantity'] as int,
      product: json['products'] as Map<String, dynamic>?,
      variant: json['product_variants'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'variant_id': variantId,
      'quantity': quantity,
      if (product != null) 'product': product,
      if (variant != null) 'variant': variant,
    };
  }
}
