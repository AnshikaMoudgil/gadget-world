class AddToCartRequest {
  final String productId;
  final String? variantId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    this.variantId,
    required this.quantity,
  });

  factory AddToCartRequest.fromJson(Map<String, dynamic> json) {
    return AddToCartRequest(
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  String? validate() {
    if (productId.isEmpty) return 'product_id is required';
    final uuid = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    if (!uuid.hasMatch(productId)) return 'product_id must be a valid UUID';
    if (variantId != null && !uuid.hasMatch(variantId!)) {
      return 'variant_id must be a valid UUID';
    }
    if (quantity <= 0) return 'quantity must be greater than 0';
    if (quantity > 99) return 'quantity cannot exceed 99';
    return null;
  }
}
