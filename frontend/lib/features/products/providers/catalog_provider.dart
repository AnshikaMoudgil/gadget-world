import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/catalog_service.dart';

class CatalogProvider with ChangeNotifier {
  final CatalogService _service = CatalogService();

  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  List<CategoryModel> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoriesError => _categoriesError;

  Future<void> fetchCategories() async {
    if (_categories.isNotEmpty) return; // Cache

    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();

    try {
      _categories = await _service.getCategories();
    } catch (e) {
      _categoriesError = e.toString();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Optional: Add products logic here if you want to store them in provider
  // For the categories screen, it's easy to just use a FutureBuilder for products
  // or a similar pattern, but we'll put it here for consistency.
  List<ProductModel> _currentCategoryProducts = [];
  bool _isLoadingProducts = false;
  String? _productsError;

  List<ProductModel> get currentCategoryProducts => _currentCategoryProducts;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get productsError => _productsError;

  Future<void> fetchProductsByCategory(String categoryId) async {
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();

    try {
      _currentCategoryProducts = await _service.getProducts(
        categoryId: categoryId,
      );
    } catch (e) {
      _productsError = e.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }
}
