import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart.dart';

class CartApiService {
  // Dynamically get base URL from environment
  static String get baseUrl {
    final configured = dotenv.env['BACKEND_URL'] ?? dotenv.env['API_BASE_URL'];
    if (configured == null || configured.trim().isEmpty) {
      throw StateError('BACKEND_URL is not configured in .env file');
    }
    final base = configured.replaceFirst(RegExp(r'/$'), '');
    return '$base/api/cart';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Cart> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load cart: ${response.body}');
    }
  }

  Future<Cart> addToCart(
    String productId,
    int quantity, {
    String? variantId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/'),
      headers: await _getHeaders(),
      body: jsonEncode(
        {'product_id': productId, 'quantity': quantity}
          ..addAll(variantId != null ? {'variant_id': variantId} : {}),
      ),
    );

    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add to cart: ${response.body}');
    }
  }

  Future<Cart> updateCartItem(String cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$cartItemId'),
      headers: await _getHeaders(),
      body: jsonEncode({'quantity': quantity}),
    );

    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update cart item: ${response.body}');
    }
  }

  Future<Cart> removeFromCart(String cartItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$cartItemId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to remove from cart: ${response.body}');
    }
  }
}
