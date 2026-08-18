import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/coupon_service.dart';

class CouponController {
  final CouponService _couponService = CouponService();

  Future<Response> validateCoupon(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (!data.containsKey('code') || !data.containsKey('cart_total')) {
        return Response.badRequest(
            body: jsonEncode({'error': 'code and cart_total are required'}),
            headers: {'Content-Type': 'application/json'});
      }

      final code = data['code'] as String;
      final cartTotal = (data['cart_total'] as num).toDouble();

      final result =
          await _couponService.validateCoupon(code, cartTotal, userId);

      return Response.ok(jsonEncode(result),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('[CouponController.validateCoupon ERROR] $e\n$st');
      return Response(400,
          body: jsonEncode(
              {'error': 'Invalid request body or validation failed'}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<Response> getAvailableCoupons(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final coupons = await _couponService.getAvailableCoupons(userId);
      return Response.ok(jsonEncode(coupons),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('[CouponController.getAvailableCoupons ERROR] $e\n$st');
      return Response.internalServerError(
          body: jsonEncode({'error': 'Failed to fetch available coupons'}),
          headers: {'Content-Type': 'application/json'});
    }
  }
}
