import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await _supabase
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return (data as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<ProductModel>> getProducts({String? categoryId}) async {
    try {
      var query = _supabase.from('products').select().eq('is_active', true);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      final data = await query.order('created_at', ascending: false);

      return (data as List).map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}
