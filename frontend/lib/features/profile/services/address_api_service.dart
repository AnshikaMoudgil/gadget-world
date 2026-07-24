import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gadget_store/features/profile/models/address.dart';

class AddressApiService {
  static String get baseUrl {
    final configured = dotenv.env['BACKEND_URL'] ?? dotenv.env['API_BASE_URL'];
    if (configured == null || configured.trim().isEmpty) {
      throw StateError('BACKEND_URL is not configured in .env file');
    }
    final base = configured.replaceFirst(RegExp(r'/$'), '');
    return '$base/api/addresses';
  }

  Future<List<Address>> getAddresses(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Address.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load addresses');
    }
  }

  Future<Address> createAddress(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Address.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to create address: $error');
    }
  }

  Future<Address> updateAddress(String token, String addressId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$addressId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return Address.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to update address: $error');
    }
  }

  Future<void> deleteAddress(String token, String addressId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$addressId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete address');
    }
  }

  Future<void> setDefaultAddress(String token, String addressId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$addressId/set-default'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set default address');
    }
  }
}
