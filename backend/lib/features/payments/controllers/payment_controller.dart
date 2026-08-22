import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../core/network/safe_error.dart';
import '../services/payment_service.dart';

class PaymentController {
  final PaymentService _paymentService = PaymentService();

  Future<Response> createOrder(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

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
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

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

  Future<Response> handleWebhook(Request request) async {
    try {
      final signature = request.headers['x-razorpay-signature'];
      if (signature == null) {
        return Response.badRequest(body: 'Missing signature');
      }
      final body = await request.readAsString();

      await _paymentService.processWebhook(signature, body);

      return Response.ok(jsonEncode({'status': 'ok'}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return SafeError.response(
        'payment.webhook',
        e,
        statusCode: 400,
        message: 'Webhook processing failed.',
      );
    }
  }
}
