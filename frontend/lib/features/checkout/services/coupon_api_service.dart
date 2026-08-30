import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coupon_response.dart';

class CouponApiException implements Exception {
  final String message;
  CouponApiException(this.message);
  @override
  String toString() => message;
}

class CouponApiService {
  static String get _baseUrl {
    final configured =
        dotenv.env['API_URL'] ??
        dotenv.env['BACKEND_URL'] ??
        dotenv.env['API_BASE_URL'];
    if (configured == null || configured.trim().isEmpty) {
      throw StateError('BACKEND_URL is not configured in .env file');
    }
    final base = configured.replaceFirst(RegExp(r'/$'), '');
    return base.endsWith('/api') ? base : '$base/api';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _parseError(String responseBody, String defaultMsg) {
    try {
      final data = jsonDecode(responseBody);
      if (data is Map && data['error'] != null) {
        return '$defaultMsg: ${data['error']}';
      }
    } catch (_) {}
    return defaultMsg;
  }

  Future<CouponResponse> validateCoupon(String code, double cartTotal) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/coupons/validate'),
      headers: await _getHeaders(),
      body: jsonEncode({'code': code, 'cart_total': cartTotal}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return CouponResponse.fromJson(jsonDecode(response.body));
    } else {
      throw CouponApiException(_parseError(response.body, 'Failed to validate coupon'));
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableCoupons() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/coupons/available'),
      headers: await _getHeaders(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw CouponApiException(_parseError(response.body, 'Failed to load available coupons'));
    }
  }
}
