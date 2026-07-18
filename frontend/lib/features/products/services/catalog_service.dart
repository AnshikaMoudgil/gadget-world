import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogService {
  final http.Client _client;

  CatalogService({http.Client? client}) : _client = client ?? http.Client();

  String get _baseUrl {
    final configured = dotenv.env['BACKEND_URL'];
    if (configured != null && configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'/$'), '');
    }
    return kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _get('/api/catalog/categories');
    final data = jsonDecode(response.body) as List;
    return data
        .map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? search,
    bool? featured,
    int? limit,
  }) async {
    final query = <String, String>{};
    if (categoryId != null && categoryId.isNotEmpty) {
      query['categoryId'] = categoryId;
    }
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (featured != null) query['featured'] = '$featured';
    if (limit != null) query['limit'] = '$limit';

    final response = await _get('/api/catalog/products', query: query);
    final data = jsonDecode(response.body) as List;
    return data
        .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ProductModel> getProduct(String id) async {
    final response = await _get(
      '/api/catalog/products/${Uri.encodeComponent(id)}',
    );
    return ProductModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  Future<ProductModel> getProductBySlug(String slug) async {
    final response = await _get(
      '/api/catalog/products/slug/${Uri.encodeComponent(slug)}',
    );
    return ProductModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  Future<http.Response> _get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Request failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body) as Map;
        message = body['error'] as String? ?? message;
      } catch (_) {
        // Keep the status-based message when the backend response is not JSON.
      }
      throw Exception(message);
    }
    return response;
  }

  void dispose() => _client.close();
}
