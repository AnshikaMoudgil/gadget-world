import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../services/payment_service.dart';

class PaymentController {
  final PaymentService _paymentService = PaymentService();

  Future<Response> createOrder(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final addressId = data['addressId'] as String?;

      final result = await _paymentService.createOrder(
        userId,
        addressId: addressId,
      );
      return Response.ok(jsonEncode(result),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('[PaymentController.createOrder ERROR] $e\n$st');
      return Response(400,
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
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
    } catch (e, st) {
      print('[PaymentController.verifyPayment ERROR] $e\n$st');
      return Response(400,
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  }

  Future<Response> getOrders(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final result = await _paymentService.getOrders(userId);
      return Response.ok(jsonEncode(result),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('[PaymentController.getOrders ERROR] $e\n$st');
      return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
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
    } catch (e, st) {
      print('[PaymentController.handleWebhook ERROR] $e\n$st');
      return Response(400,
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  }
}
