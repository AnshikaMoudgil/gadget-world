import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/env.dart';

class RazorpayService {
  final String _baseUrl = 'https://api.razorpay.com/v1';
  final String _keyId =
      Env.getOrNull('RAZORPAY_KEY_ID') ?? Env.get('RAZORPAY_KEY_ID_A');
  final String _keySecret =
      Env.getOrNull('RAZORPAY_KEY_SECRET') ?? Env.get('RAZORPAY_KEY_SECRET_A');

  String get _basicAuth {
    final credentials = '$_keyId:$_keySecret';
    final bytes = utf8.encode(credentials);
    final base64Str = base64.encode(bytes);
    return 'Basic $base64Str';
  }

  Future<Map<String, dynamic>> createOrder({
    required int amountSubunits,
    required String currency,
    required String receipt,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders'),
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amountSubunits,
        'currency': currency,
        'receipt': receipt,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create Razorpay order: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> fetchPayment(String paymentId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payments/$paymentId'),
      headers: {
        'Authorization': _basicAuth,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch Razorpay payment: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> capturePayment({
    required String paymentId,
    required int amountSubunits,
    required String currency,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/$paymentId/capture'),
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amount': amountSubunits,
        'currency': currency,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    }

    throw Exception('Failed to capture Razorpay payment: ${response.body}');
  }

  Future<Map<String, dynamic>> refundPayment(String paymentId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/$paymentId/refund'),
      headers: {
        'Authorization': _basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'speed': 'normal'}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    }

    throw Exception('Failed to refund Razorpay payment: ${response.body}');
  }
}
