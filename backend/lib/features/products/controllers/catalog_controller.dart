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

  /// `GET /categories`
  Future<Response> getCategories(Request request) async {
    final result = await SupabaseDb.query<List<Map<String, dynamic>>>(() async {
      return await SupabaseDb.client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);
    });

    if (result.isError) {
      return _error(result.statusCode, result.errorMessage ?? 'Failed to fetch categories');
    }

    final categories = result.data!.map((e) => CategoryModel.fromJson(e)).toList();
    return _ok(categories.map((c) => c.toJson()).toList());
  }

  /// `GET /products?categoryId={id}`
  Future<Response> getProducts(Request request) async {
    final categoryId = request.url.queryParameters['categoryId'];

    final result = await SupabaseDb.query<List<Map<String, dynamic>>>(() async {
      var query = SupabaseDb.client.from('products').select().eq('is_active', true);
      
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      
      return await query.order('created_at', ascending: false);
    });

    if (result.isError) {
      return _error(result.statusCode, result.errorMessage ?? 'Failed to fetch products');
    }

    final products = result.data!.map((e) => ProductModel.fromJson(e)).toList();
    return _ok(products.map((p) => p.toJson()).toList());
  }
}
