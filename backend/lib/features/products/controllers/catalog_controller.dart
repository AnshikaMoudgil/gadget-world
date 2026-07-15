import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../../core/database/supabase_db.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogController {
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Response _error(int status, String message) {
    return Response(status,
        body: jsonEncode({'error': message}), headers: _jsonHeaders);
  }

  Response _ok(Object? body) {
    return Response.ok(jsonEncode(body), headers: _jsonHeaders);
  }

  Future<Response> getCategories(Request request) async {
    final result = await SupabaseDb.query<List<Map<String, dynamic>>>(() async {
      return await SupabaseDb.client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);
    });

    if (result.isError) {
      return _error(
          result.statusCode, result.message ?? 'Failed to fetch categories');
    }

    final categories =
        result.data!.map((e) => CategoryModel.fromJson(e)).toList();
    return _ok(categories.map((c) => c.toJson()).toList());
  }

  Future<Response> getProducts(Request request) async {
    final params = request.url.queryParameters;
    final categoryId = params['categoryId'];
    final search = params['search']?.trim();
    final featured = params['featured'];
    final limit = int.tryParse(params['limit'] ?? '');

    final result = await SupabaseDb.query<List<Map<String, dynamic>>>(() async {
      var query = SupabaseDb.client
          .from('products')
          .select('*, categories(name, slug), brands(name, slug)')
          .eq('is_active', true);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      if (featured == 'true') {
        query = query.eq('is_featured', true);
      }
      if (search != null && search.isNotEmpty) {
        final escaped = search.replaceAll(',', ' ');
        query = query.or('name.ilike.%$escaped%,description.ilike.%$escaped%');
      }

      var ordered = query.order('created_at', ascending: false);
      if (limit != null && limit > 0) {
        ordered = ordered.limit(limit);
      }
      return await ordered;
    });

    if (result.isError) {
      return _error(
          result.statusCode, result.message ?? 'Failed to fetch products');
    }

    final products = result.data!.map((e) => ProductModel.fromJson(e)).toList();
    return _ok(products.map((p) => p.toJson()).toList());
  }

  Future<Response> getProduct(Request request) async {
    final segments = request.url.pathSegments;
    final id = segments.isEmpty ? null : segments.last;
    if (id == null || id.isEmpty) {
      return _error(400, 'Product id is required');
    }

    return _getProductBy('id', id);
  }

  Future<Response> getProductBySlug(Request request) async {
    final segments = request.url.pathSegments;
    final slug = segments.isEmpty ? null : segments.last;
    if (slug == null || slug.isEmpty) {
      return _error(400, 'Product slug is required');
    }

    return _getProductBy('slug', slug);
  }

  Future<Response> _getProductBy(String field, String value) async {
    final result = await SupabaseDb.querySingle<Map<String, dynamic>>(() async {
      return await SupabaseDb.client.from('products').select('''
            *,
            categories(name, slug),
            brands(name, slug),
            product_specs(*),
            product_features(*),
            product_variants(*)
          ''').eq(field, value).eq('is_active', true).maybeSingle();
    });

    if (result.isError) {
      return _error(result.statusCode, result.message ?? 'Product not found');
    }

    return _ok(ProductModel.fromJson(result.data!).toJson());
  }
}
