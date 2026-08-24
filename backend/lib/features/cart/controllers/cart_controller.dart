import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../core/database/db_result.dart';
import '../services/cart_service.dart';
import '../models/add_to_cart_request.dart';

class CartController {
  final CartService _cartService = CartService();

  Map<String, dynamic> _errorBody(DbResult<Object?> result) => {
        'error': result.message,
        if (result.errorId != null) 'error_id': result.errorId,
      };

  Future<Response> getCart(Request request) async {
    final userId = request.context['userId'] as String;
    final result = await _cartService.getCart(userId);

    if (result.isError) {
      return Response(result.statusCode,
          body: jsonEncode(_errorBody(result)),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode(result.data!.toJson()),
        headers: {'Content-Type': 'application/json'});
  }

  Future<Response> addToCart(Request request) async {
    final userId = request.context['userId'] as String;

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final addRequest = AddToCartRequest.fromJson(data);

      final validationError = addRequest.validate();
      if (validationError != null) {
        return Response(400,
            body: jsonEncode({'error': validationError}),
            headers: {'Content-Type': 'application/json'});
      }

      final result = await _cartService.addToCart(userId, addRequest);
      if (result.isError) {
        return Response(result.statusCode,
            body: jsonEncode(_errorBody(result)),
            headers: {'Content-Type': 'application/json'});
      }

      return Response.ok(jsonEncode(result.data!.toJson()),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response(400,
          body: jsonEncode({'error': 'Invalid request body'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<Response> updateCartItem(Request request, String itemId) async {
    final userId = request.context['userId'] as String;

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (!data.containsKey('quantity')) {
        return Response(400,
            body: jsonEncode({'error': 'quantity is required'}),
            headers: {'Content-Type': 'application/json'});
      }

      final quantity = data['quantity'] as int;
      final result =
          await _cartService.updateCartItemQuantity(userId, itemId, quantity);

      if (result.isError) {
        return Response(result.statusCode,
            body: jsonEncode(_errorBody(result)),
            headers: {'Content-Type': 'application/json'});
      }

      return Response.ok(jsonEncode(result.data!.toJson()),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response(400,
          body: jsonEncode({'error': 'Invalid request body'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<Response> removeFromCart(Request request, String itemId) async {
    final userId = request.context['userId'] as String;

    final result = await _cartService.removeFromCart(userId, itemId);

    if (result.isError) {
      return Response(result.statusCode,
          body: jsonEncode(_errorBody(result)),
          headers: {'Content-Type': 'application/json'});
    }

    return Response.ok(jsonEncode(result.data!.toJson()),
        headers: {'Content-Type': 'application/json'});
  }
}
