class OrderItem {
  final String id;
  final String productId;
  final int quantity;
  final double amount;
  final Map<String, dynamic>? productDetails;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.amount,
    this.productDetails,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      quantity: json['quantity'] ?? 1,
      amount: (json['total_price'] as num? ?? 0).toDouble(),
      productDetails: json['products'] as Map<String, dynamic>?,
    );
  }
}

class Order {
  final String id;
  final String razorpayOrderId;
  final String status;
  final double amount;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.razorpayOrderId,
    required this.status,
    required this.amount,
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['order_items'] as List?) ?? [];

    // razorpay_order_id might be inside payments array if not in orders table directly
    String rzpOrderId = json['razorpay_order_id'] ?? '';
    if (rzpOrderId.isEmpty &&
        json['payments'] != null &&
        (json['payments'] as List).isNotEmpty) {
      rzpOrderId = json['payments'][0]['razorpay_order_id'] ?? '';
    }

    return Order(
      id: json['id'] ?? '',
      razorpayOrderId: rzpOrderId,
      status: json['status'] ?? 'pending',
      amount: (json['total_amount'] as num? ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      items: itemsList.map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}
