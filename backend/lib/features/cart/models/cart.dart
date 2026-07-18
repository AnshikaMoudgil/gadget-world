import 'cart_item.dart';

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var itemsList = json['cart_items'] as List<dynamic>? ?? [];
    return Cart(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      items: itemsList
          .map((i) => CartItem.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
