import 'package:flutter/foundation.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/catalog_service.dart';

class CatalogProvider with ChangeNotifier {
  final CatalogService _service;

  CatalogProvider({CatalogService? service})
    : _service = service ?? CatalogService();

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

  Future<void> fetchCategories({bool forceRefresh = false}) async {
    if (_categories.isNotEmpty && !forceRefresh) return;
    _isLoadingCategories = true;
    _categoriesError = null;
    notifyListeners();
    try {
      _categories = await _service.getCategories();
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
      _products = await _service.getProducts();
    } catch (error) {
      _productsError = error.toString();
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchFeaturedProducts({bool forceRefresh = false}) async {
    if (_featuredProducts.isNotEmpty && !forceRefresh) return;
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();
    try {
      _featuredProducts = await _service.getProducts(featured: true);
    } catch (error) {
      _productsError = error.toString();
    } finally {
      _isLoadingProducts = false;
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

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
