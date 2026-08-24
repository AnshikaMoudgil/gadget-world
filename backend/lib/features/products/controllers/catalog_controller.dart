import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../../core/database/supabase_db.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogController {
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  Response _error(int status, String message, [String? errorId]) {
    return Response(status,
        body: jsonEncode({
          'error': message,
          if (errorId != null) 'error_id': errorId,
        }),
        headers: _jsonHeaders);
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
      return _error(result.statusCode,
          result.message ?? 'Failed to fetch categories', result.errorId);
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
    final parsedLimit = int.tryParse(params['limit'] ?? '24');
    final page = int.tryParse(params['page'] ?? '1');

    final minPrice = double.tryParse(params['minPrice'] ?? '');
    final maxPrice = double.tryParse(params['maxPrice'] ?? '');
    final brandId = params['brandId'];
    final inStock = params['inStock'];
    final sort = params['sort'] ?? 'newest';

    if (parsedLimit == null || parsedLimit < 1 || parsedLimit > 100) {
      return _error(400, 'limit must be between 1 and 100');
    }
    if (page == null || page < 1 || page > 10000) {
      return _error(400, 'page must be between 1 and 10000');
    }
    if (search != null && search.length > 100) {
      return _error(400, 'search cannot exceed 100 characters');
    }
    final safeSearch = search
        ?.replaceAll(RegExp(r'[^a-zA-Z0-9\s-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (categoryId != null && categoryId.length > 100 ||
        brandId != null && brandId.length > 100) {
      return _error(400, 'filter value is too long');
    }
    if (params.containsKey('minPrice') && minPrice == null ||
        params.containsKey('maxPrice') && maxPrice == null) {
      return _error(400, 'price filters must be numeric');
    }
    if (minPrice != null && (minPrice < 0 || minPrice > 10000000) ||
        maxPrice != null && (maxPrice < 0 || maxPrice > 10000000) ||
        minPrice != null && maxPrice != null && minPrice > maxPrice) {
      return _error(400, 'price range is invalid');
    }
    if (featured != null && featured != 'true' && featured != 'false' ||
        inStock != null && inStock != 'true' && inStock != 'false') {
      return _error(400, 'boolean filters must be true or false');
    }
    if (!{'price_asc', 'price_desc', 'newest', 'popular'}.contains(sort)) {
      return _error(400, 'sort value is invalid');
    }

    final limit = parsedLimit;
    final offset = (page - 1) * limit;

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
      if (safeSearch != null && safeSearch.isNotEmpty) {
        query = query.or(
          'name.ilike.%$safeSearch%,description.ilike.%$safeSearch%',
        );
      }

      // Apply new filters
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      if (brandId != null && brandId.isNotEmpty && brandId != 'All') {
        final isUuid = RegExp(
                r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
                caseSensitive: false)
            .hasMatch(brandId);

        if (isUuid) {
          query = query.eq('brand_id', brandId);
        } else {
          final brandRes = await SupabaseDb.client
              .from('brands')
              .select('id')
              .eq('name', brandId)
              .maybeSingle();
          if (brandRes != null) {
            query = query.eq('brand_id', brandRes['id']);
          } else {
            query = query.eq('brand_id',
                '00000000-0000-0000-0000-000000000000'); // Force empty
          }
        }
      }
      if (inStock == 'true') {
        query = query.gt('stock_quantity', 0);
      } else if (inStock == 'false') {
        query = query.eq('stock_quantity', 0);
      }

      // Apply sorting
      dynamic ordered = query;
      if (sort == 'price_asc') {
        ordered = query.order('price', ascending: true);
      } else if (sort == 'price_desc') {
        ordered = query.order('price', ascending: false);
      } else if (sort == 'popular') {
        ordered = query
            .order('is_featured', ascending: false)
            .order('created_at', ascending: false);
      } else {
        // default to newest
        ordered = query.order('created_at', ascending: false);
      }

      return await ordered.range(offset, offset + limit - 1);
    });

    if (result.isError) {
      return _error(result.statusCode,
          result.message ?? 'Failed to fetch products', result.errorId);
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
      return _error(result.statusCode, result.message ?? 'Product not found',
          result.errorId);
    }

    return _ok(ProductModel.fromJson(result.data!).toJson());
  }
}
