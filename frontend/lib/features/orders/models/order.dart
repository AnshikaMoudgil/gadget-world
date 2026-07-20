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
      amount: (json['amount_subunits'] as num? ?? 0) / 100,
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
    final itemsList = (json['payment_items'] as List?) ?? [];
    return Order(
      id: json['id'] ?? '',
      razorpayOrderId: json['razorpay_order_id'] ?? '',
      status: json['status'] ?? 'pending',
      amount: (json['amount_subunits'] as num? ?? 0) / 100,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      items: itemsList.map((item) => OrderItem.fromJson(item)).toList(),
    );
  }
}
