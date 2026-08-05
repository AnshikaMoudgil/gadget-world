import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentApiService {
  static String get _baseUrl {
    final configured =
        dotenv.env['API_URL'] ??
        dotenv.env['BACKEND_URL'] ??
        dotenv.env['API_BASE_URL'];
    if (configured == null || configured.trim().isEmpty) {
      throw StateError('API_URL or BACKEND_URL is not configured in .env file');
    }
    final base = configured.replaceFirst(RegExp(r'/$'), '');
    return base.endsWith('/api') ? base : '$base/api';
  }

  Future<Map<String, dynamic>> createOrder({
    required String token,
    required String addressId,
    required double shippingFee,
    required double discount,
    String? couponCode,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/create-order'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'addressId': addressId,
        'shippingFee': shippingFee,
        'discount': discount,
        if (couponCode != null) 'couponCode': couponCode,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create order: ${response.body}');
    }
  }

  Future<void> verifyPayment({
    required String token,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/verify'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to verify payment: ${response.body}');
    }
  }

  Future<List<dynamic>> getOrders(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payments/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch orders: ${response.body}');
    }
  }
}
