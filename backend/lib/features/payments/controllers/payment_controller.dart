import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../../core/network/safe_error.dart';
import '../../../core/network/json_request.dart';
import '../services/payment_service.dart';

class PaymentController {
  static const _maxWebhookBytes = 256 * 1024;
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

  Future<Response> handleWebhook(Request request) async {
    try {
      final signature = request.headers['x-razorpay-signature'];
      final eventId = request.headers['x-razorpay-event-id'];
      if (signature == null || signature.isEmpty) {
        return Response.badRequest(body: 'Missing signature');
      }
      if (eventId == null || eventId.isEmpty || eventId.length > 200) {
        return Response.badRequest(body: 'Missing or invalid event ID');
      }
      final declaredLength =
          int.tryParse(request.headers['content-length'] ?? '');
      if (declaredLength != null && declaredLength > _maxWebhookBytes) {
        return Response(413, body: 'Webhook body is too large');
      }
      final bytes = <int>[];
      await for (final chunk in request.read()) {
        bytes.addAll(chunk);
        if (bytes.length > _maxWebhookBytes) {
          return Response(413, body: 'Webhook body is too large');
        }
      }
      final body = utf8.decode(bytes);

      await _paymentService.processWebhook(eventId, signature, body);

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
