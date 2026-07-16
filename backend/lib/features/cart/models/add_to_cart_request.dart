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
    if (quantity <= 0) return 'quantity must be greater than 0';
    return null;
  }
}
