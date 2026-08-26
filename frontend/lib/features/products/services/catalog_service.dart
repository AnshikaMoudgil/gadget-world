import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogService {
  static const int _pageSize = 100;
  static const int _maxPages = 100;
  final http.Client _client;
  final String? _configuredBaseUrl;

  CatalogService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _configuredBaseUrl = baseUrl;

  String get _baseUrl {
    final configured =
        _configuredBaseUrl ??
        dotenv.env['BACKEND_URL'] ??
        dotenv.env['API_BASE_URL'];
    if (configured == null || configured.trim().isEmpty) {
      throw StateError('BACKEND_URL is not configured in .env file');
    }
    return configured.replaceFirst(RegExp(r'/$'), '');
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
    int limit = _pageSize,
    double? minPrice,
    double? maxPrice,
    String? brandId,
    bool? inStock,
    String? sort,
  }) async {
    if (limit < 1 || limit > _pageSize) {
      throw ArgumentError.value(limit, 'limit', 'must be between 1 and 100');
    }

    final baseQuery = <String, String>{};
    if (categoryId != null && categoryId.isNotEmpty) {
      baseQuery['categoryId'] = categoryId;
    }
    if (search != null && search.trim().isNotEmpty) {
      baseQuery['search'] = search.trim();
    }
    if (featured != null) baseQuery['featured'] = '$featured';
    if (minPrice != null) baseQuery['minPrice'] = '$minPrice';
    if (maxPrice != null) baseQuery['maxPrice'] = '$maxPrice';
    if (brandId != null) baseQuery['brandId'] = brandId;
    if (inStock != null) baseQuery['inStock'] = '$inStock';
    if (sort != null) baseQuery['sort'] = sort;

    final products = <ProductModel>[];
    for (var page = 1; page <= _maxPages; page++) {
      final response = await _get(
        '/api/catalog/products',
        query: {...baseQuery, 'page': '$page', 'limit': '$limit'},
      );
      final data = jsonDecode(response.body) as List;
      products.addAll(
        data.map(
          (item) => ProductModel.fromJson(Map<String, dynamic>.from(item)),
        ),
      );
      if (data.length < limit) return products;
    }

    throw StateError('Catalog pagination exceeded the safe page limit');
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
