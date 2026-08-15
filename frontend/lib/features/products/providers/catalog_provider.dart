import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/catalog_service.dart';

class CatalogProvider with ChangeNotifier {
  final CatalogService _service;

  CatalogProvider({CatalogService? service})
    : _service = service ?? CatalogService();

  List<String> _recentSearches = [];
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _currentCategoryProducts = [];
  List<ProductModel> _searchResults = [];
  ProductModel? _selectedProduct;
  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;
  bool _isLoadingProduct = false;
  String? _categoriesError;
  String? _productsError;
  String? _productError;

  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<ProductModel> get products => List.unmodifiable(_products);
  List<ProductModel> get featuredProducts =>
      List.unmodifiable(_featuredProducts);
  List<ProductModel> get currentCategoryProducts =>
      List.unmodifiable(_currentCategoryProducts);
  List<ProductModel> get searchResults => List.unmodifiable(_searchResults);
  ProductModel? get selectedProduct => _selectedProduct;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingProduct => _isLoadingProduct;
  String? get categoriesError => _categoriesError;
  String? get productsError => _productsError;
  String? get productError => _productError;

  // Active filters
  double? _minPrice;
  double? _maxPrice;
  String? _filterBrandId;
  bool? _inStock;
  String? _sortBy;

  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get filterBrandId => _filterBrandId;
  bool? get inStock => _inStock;
  String? get sortBy => _sortBy;

  bool get hasActiveFilters =>
      _minPrice != null ||
      _maxPrice != null ||
      _filterBrandId != null ||
      _inStock != null ||
      _sortBy != null;

  void setFilters({
    double? minPrice,
    double? maxPrice,
    String? brandId,
    bool? inStock,
    String? sortBy,
  }) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _filterBrandId = brandId == 'All' ? null : brandId;
    _inStock = inStock;
    _sortBy = sortBy;
    notifyListeners();
    fetchProducts(forceRefresh: true);
  }

  void clearFilters() {
    _minPrice = null;
    _maxPrice = null;
    _filterBrandId = null;
    _inStock = null;
    _sortBy = null;
    notifyListeners();
    fetchProducts(forceRefresh: true);
  }

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (_categories.isNotEmpty && !forceRefresh) return;
    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();
    try {
      final fetched = await _service.getCategories();
      _categories = fetched.where((c) => c.name.toLowerCase() != 'computer softwares').toList();
    } catch (error) {
      _categoriesError = error.toString();
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts({bool forceRefresh = false}) async {
    if (_products.isNotEmpty && !forceRefresh) return;
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();
    try {
      _products = await _service.getProducts(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        brandId: _filterBrandId,
        inStock: _inStock,
        sort: _sortBy,
      );
    } catch (error) {
      _productsError = error.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  bool _isLoadingFeatured = false;
  String? _featuredError;

  bool get isLoadingFeatured => _isLoadingFeatured;
  String? get featuredError => _featuredError;

  Future<void> fetchFeaturedProducts({bool forceRefresh = false}) async {
    if (_featuredProducts.isNotEmpty && !forceRefresh) return;
    _isLoadingFeatured = true;
    _featuredError = null;
    notifyListeners();
    try {
      _featuredProducts = await _service.getProducts(featured: true);
    } catch (error) {
      _featuredError = error.toString();
    } finally {
      _isLoadingFeatured = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategory(String categoryId) async {
    _isLoadingProducts = true;
    _productsError = null;
    _currentCategoryProducts = [];
    notifyListeners();
    try {
      _currentCategoryProducts = await _service.getProducts(
        categoryId: categoryId,
      );
    } catch (error) {
      _productsError = error.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();
    try {
      _searchResults = await _service.getProducts(search: query);
    } catch (error) {
      _productsError = error.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> fetchProduct(String id) async {
    _isLoadingProduct = true;
    _productError = null;
    _selectedProduct = null;
    notifyListeners();
    try {
      _selectedProduct = await _service.getProduct(id);
      return _selectedProduct;
    } catch (error) {
      _productError = error.toString();
      return null;
    } finally {
      _isLoadingProduct = false;
      notifyListeners();
    }
  }

  Future<ProductModel?> fetchProductBySlug(String slug) async {
    _isLoadingProduct = true;
    _productError = null;
    _selectedProduct = null;
    notifyListeners();
    try {
      _selectedProduct = await _service.getProductBySlug(slug);
      return _selectedProduct;
    } catch (error) {
      _productError = error.toString();
      return null;
    } finally {
      _isLoadingProduct = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList('recent_searches') ?? [];
    notifyListeners();
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 10) _recentSearches.removeLast();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  Future<void> removeRecentSearch(String query) async {
    _recentSearches.remove(query);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_searches', _recentSearches);
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
