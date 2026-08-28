import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../core/network/safe_error.dart';
import '../../../core/network/json_request.dart';
import '../services/payment_service.dart';

class PaymentController {
  PaymentService? _paymentServiceInstance;
  PaymentService get _paymentService =>
      _paymentServiceInstance ??= PaymentService();

  Future<Response> createOrder(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final data = await readJsonObject(
        request,
        allowedKeys: {'addressId', 'couponCode'},
        requiredKeys: {'addressId'},
      );

      final addressId = data['addressId'] as String?;
      final couponCode = data['couponCode'] as String?;

      final result = await _paymentService.createOrder(
        userId,
        addressId: addressId,
        couponCode: couponCode,
      );

      return Response.ok(jsonEncode(result),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return SafeError.response(
        'payment.create_order',
        e,
        statusCode: 400,
        message: 'Unable to create the payment order.',
      );
    }
  }

  Future<Response> verifyPayment(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final data = await readJsonObject(
        request,
        allowedKeys: {
          'razorpayOrderId',
          'razorpayPaymentId',
          'razorpaySignature',
        },
        requiredKeys: {
          'razorpayOrderId',
          'razorpayPaymentId',
          'razorpaySignature',
        },
      );

      await _paymentService.verifyPayment(
        userId: userId,
        razorpayOrderId: data['razorpayOrderId'] ?? '',
        razorpayPaymentId: data['razorpayPaymentId'] ?? '',
        razorpaySignature: data['razorpaySignature'] ?? '',
      );

      return Response.ok(jsonEncode({'status': 'success'}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return SafeError.response(
        'payment.verify',
        e,
        statusCode: 400,
        message: 'Payment verification failed.',
      );
    }
  }

  Future<Response> getOrders(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final result = await _paymentService.getOrders(userId);
      return Response.ok(jsonEncode(result),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return SafeError.response(
        'payment.get_orders',
        e,
        message: 'Unable to retrieve orders.',
      );
    }
  }
}
