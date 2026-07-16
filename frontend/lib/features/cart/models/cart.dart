class CartItem {
  final String id;
  final String productId;
  final String? variantId;
  final int quantity;
  final Map<String, dynamic>? product;
  final Map<String, dynamic>? variant;

  CartItem({
    required this.id,
    required this.productId,
    this.variantId,
    required this.quantity,
    this.product,
    this.variant,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['product_id'],
      variantId: json['variant_id'],
      quantity: json['quantity'],
      product: json['product'],
      variant: json['variant'],
    );
  }
}

class Cart {
  final String id;
  final List<CartItem> items;

  Cart({required this.id, required this.items});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }
}
