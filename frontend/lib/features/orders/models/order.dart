import 'package:gadget_store/features/profile/models/address.dart';

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
      amount: json['total_price'] != null
          ? (double.tryParse(json['total_price'].toString()) ?? 0.0)
          : 0.0,
      productDetails: json['products'] as Map<String, dynamic>?,
    );
  }
}

class Order {
  final String id;
  final String razorpayOrderId;
  final String status;
  final String paymentStatus;
  final double amount;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final List<OrderItem> items;
  final Address? shippingAddress;

  Order({
    required this.id,
    required this.razorpayOrderId,
    required this.status,
    required this.paymentStatus,
    required this.amount,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.createdAt,
    this.shippedAt,
    this.deliveredAt,
    this.items = const [],
    this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['order_items'] as List?) ?? [];
    final shippingAddressJson =
        json['shipping_address_snapshot'] ?? json['user_addresses'];

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
      paymentStatus: json['payment_status'] ?? 'unpaid',
      amount: json['total_amount'] != null
          ? (double.tryParse(json['total_amount'].toString()) ?? 0.0)
          : 0.0,
      subtotal: json['subtotal'] != null
          ? (double.tryParse(json['subtotal'].toString()) ?? 0.0)
          : 0.0,
      shippingFee: json['shipping_fee'] != null
          ? (double.tryParse(json['shipping_fee'].toString()) ?? 0.0)
          : 0.0,
      discount: json['discount_amount'] != null
          ? (double.tryParse(json['discount_amount'].toString()) ?? 0.0)
          : 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      items: itemsList.map((item) => OrderItem.fromJson(item)).toList(),
      shippingAddress: shippingAddressJson != null
          ? (shippingAddressJson is List && shippingAddressJson.isNotEmpty)
                ? Address.fromJson(shippingAddressJson.first)
                : (shippingAddressJson is Map)
                ? Address.fromJson(
                    Map<String, dynamic>.from(shippingAddressJson),
                  )
                : null
          : null,
    );
  }
}
