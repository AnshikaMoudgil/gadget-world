import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/cart_api_service.dart';
import '../../checkout/services/coupon_api_service.dart';

class CartProvider extends ChangeNotifier {
  final CartApiService _apiService = CartApiService();
  final CouponApiService _couponApiService = CouponApiService();

  Cart? _cart;
  bool _isLoading = false;
  String? _error;

  String? _appliedCouponCode;
  double _discountAmount = 0.0;
  String? _discountType;
  int _pendingItemCount = 0;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get appliedCouponCode => _appliedCouponCode;
  String? get discountType => _discountType;

  int get itemCount {
    if (_cart == null) return 0;
    return _cart!.items.fold(0, (sum, item) => sum + item.quantity) +
        _pendingItemCount;
  }

  double get subtotal {
    if (_cart == null) return 0.0;
    double total = 0;
    for (var item in _cart!.items) {
      final price = item.product?['price'] != null
          ? (double.tryParse(item.product!['price'].toString()) ?? 0.0)
          : 0.0;
      total += price * item.quantity;
    }
    return total;
  }

  double get discount {
    return _discountAmount;
  }

  double get shippingFee {
    if (_cart == null || _cart!.items.isEmpty) return 0.0;
    if (_discountType == 'free_shipping') return 0.0;
    return subtotal > 50000 ? 0.0 : 299.0;
  }

  double get total {
    return subtotal - discount + shippingFee;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> applyCoupon(String code) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _couponApiService.validateCoupon(code, subtotal);
      if (res.valid) {
        _appliedCouponCode = code;
        _discountAmount = res.discountAmount;
        _discountType = res.discountType;
      } else {
        _setError(res.message);
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void removeCoupon() {
    _appliedCouponCode = null;
    _discountAmount = 0.0;
    _discountType = null;
    notifyListeners();
  }

  void _checkCouponValidity() {
    if (_appliedCouponCode != null) {
      // Re-validate silently or clear. For safety, clear if cart becomes empty or very small.
      if (subtotal == 0) {
        removeCoupon();
      } else {
        // Just clear to make them apply again, or re-apply silently.
        // Let's clear to be safe.
        removeCoupon();
      }
    }
  }

  Future<void> loadCart() async {
    _setLoading(true);
    _setError(null);
    try {
      _cart = await _apiService.getCart();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart(
    String productId,
    int quantity, {
    String? variantId,
  }) async {
    _setLoading(true);
    _pendingItemCount += quantity;
    notifyListeners();
    _setError(null);
    try {
      _cart = await _apiService.addToCart(
        productId,
        quantity,
        variantId: variantId,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _pendingItemCount -= quantity;
      if (_pendingItemCount < 0) _pendingItemCount = 0;
      _checkCouponValidity();
      _setLoading(false);
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    _setLoading(true);
    final previousCart = _cart;
    if (_cart != null) {
      _cart = Cart(
        id: _cart!.id,
        items: _cart!.items
            .map(
              (item) => item.id == cartItemId
                  ? CartItem(
                      id: item.id,
                      productId: item.productId,
                      variantId: item.variantId,
                      quantity: quantity,
                      product: item.product,
                      variant: item.variant,
                    )
                  : item,
            )
            .toList(),
      );
      notifyListeners();
    }
    _setError(null);
    try {
      _cart = await _apiService.updateCartItem(cartItemId, quantity);
    } catch (e) {
      _cart = previousCart;
      _setError(e.toString());
    } finally {
      _checkCouponValidity();
      _setLoading(false);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _setLoading(true);
    final previousCart = _cart;
    if (_cart != null) {
      _cart = Cart(
        id: _cart!.id,
        items: _cart!.items.where((item) => item.id != cartItemId).toList(),
      );
      notifyListeners();
    }
    _setError(null);
    try {
      _cart = await _apiService.removeFromCart(cartItemId);
    } catch (e) {
      _cart = previousCart;
      _setError(e.toString());
    } finally {
      _checkCouponValidity();
      _setLoading(false);
    }
  }

  void clearCartLocal() {
    _cart = null;
    _appliedCouponCode = null;
    _discountAmount = 0.0;
    _discountType = null;
    _pendingItemCount = 0;
    notifyListeners();
  }
}
