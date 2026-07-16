import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../services/cart_api_service.dart';

class CartProvider extends ChangeNotifier {
  final CartApiService _apiService = CartApiService();
  
  Cart? _cart;
  bool _isLoading = false;
  String? _error;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount {
    if (_cart == null) return 0;
    return _cart!.items.fold(0, (sum, item) => sum + item.quantity);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
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

  Future<void> addToCart(String productId, int quantity, {String? variantId}) async {
    _setLoading(true);
    _setError(null);
    try {
      _cart = await _apiService.addToCart(productId, quantity, variantId: variantId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    _setLoading(true);
    _setError(null);
    try {
      _cart = await _apiService.updateCartItem(cartItemId, quantity);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _setLoading(true);
    _setError(null);
    try {
      _cart = await _apiService.removeFromCart(cartItemId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearCartLocal() {
    _cart = null;
    notifyListeners();
  }
}
