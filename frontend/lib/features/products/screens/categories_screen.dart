import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import '../models/category_model.dart';
import '../providers/catalog_provider.dart';
import 'search_results_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  CategoryModel? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CatalogProvider>(context, listen: false);
      provider.fetchCategories();
      provider
          .fetchProducts(); // Default fetch all products for "Explore All" / "SALE"
    });
  }

  void _onCategorySelected(CategoryModel? category) {
    setState(() {
      _selectedCategory = category;
    });
    final provider = Provider.of<CatalogProvider>(context, listen: false);
    if (category == null) {
      provider.fetchProducts();
    } else {
      provider.fetchProductsByCategory(category.id);
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SearchResultsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Search products...',
                        style: TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.search,
                      color: AppTheme.black,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(CatalogProvider provider) {
    if (provider.isLoadingCategories) {
      return const SizedBox(
        width: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final categories = provider.categories;

    return Container(
      width: 100,
      color: const Color(0xFFF5F5F5), // Light grey background like reference
      child: ListView.builder(
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategory == null;
            return _buildSidebarItem(
              title: 'Explore All', // First one as 'Explore All'
              isSelected: isSelected,
              onTap: () => _onCategorySelected(null),
              isSpecial: false,
            );
          }
          final category = categories[index - 1];
          final isSelected = _selectedCategory?.id == category.id;
          return _buildSidebarItem(
            title: category.name.toUpperCase(),
            isSelected: isSelected,
            onTap: () => _onCategorySelected(category),
            isSpecial: false,
          );
        },
      ),
    );
  }

  Widget _buildSidebarItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isSpecial,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.white : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSpecial
                      ? Colors.red
                      : (isSelected ? AppTheme.black : AppTheme.greyText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightContent(CatalogProvider provider) {
    final isLoading = provider.isLoadingProducts;
    final products = _selectedCategory == null
        ? provider.products
        : provider.currentCategoryProducts;
    final title = _selectedCategory == null
        ? 'Explore All'
        : _selectedCategory!.name.toUpperCase();

    return Expanded(
      child: Container(
        color: AppTheme.white,
        child: Column(
          children: [
            // Content Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Grid Content
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                0.65, // Adjust for product card ratio
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard.fromProduct(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          onAdd: () {
                            if (product.stockQuantity > 0) {
                              context.read<CartProvider>().addToCart(
                                product.id,
                                1,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${product.name} added to cart',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<CatalogProvider>(
                    builder: (context, provider, child) =>
                        _buildLeftSidebar(provider),
                  ),
                  Consumer<CatalogProvider>(
                    builder: (context, provider, child) =>
                        _buildRightContent(provider),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
