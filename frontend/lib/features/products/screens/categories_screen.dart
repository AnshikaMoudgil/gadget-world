import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import '../models/category_model.dart';
import '../providers/catalog_provider.dart';
import 'search_results_screen.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';

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
      provider.fetchProducts(); // Fetch all products for "Explore All"
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

  Widget _buildSidebarItem({
    required String title,
    String? subtitle,
    String? imageUrl,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    Widget buildImageOrIcon() {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final isNetwork =
            imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isNetwork
              ? Image.network(
                  imageUrl,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.category_outlined,
                    size: 20,
                    color: AppTheme.white,
                  ),
                )
              : Image.asset(
                  imageUrl,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.category_outlined,
                    size: 20,
                    color: AppTheme.white,
                  ),
                ),
        );
      }
      return Icon(
        icon ?? Icons.category_outlined,
        size: 20,
        color: AppTheme.white,
      );
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.black
              : AppTheme.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppTheme.white, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: buildImageOrIcon(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: AppTheme.white,
                      fontSize: 14,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.white.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(CatalogProvider provider, bool isMobile) {
    if (provider.isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.categoriesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Error: ${provider.categoriesError}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final categories = provider.categories;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final isSelected = _selectedCategory == null;
          return _buildSidebarItem(
            title: 'Explore All',
            subtitle: 'View all products',
            icon: Icons.grid_view_rounded,
            isSelected: isSelected,
            onTap: () {
              _onCategorySelected(null);
              if (isMobile) Navigator.pop(context); // Close drawer
            },
          );
        }
        final category = categories[index - 1];
        final isSelected = _selectedCategory?.id == category.id;
        return _buildSidebarItem(
          title: category.name,
          imageUrl: category.imageUrl,
          icon: Icons.category_outlined,
          isSelected: isSelected,
          onTap: () {
            _onCategorySelected(category);
            if (isMobile) Navigator.pop(context); // Close drawer
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      drawer: isMobile
          ? Drawer(
              child: SafeArea(
                child: Consumer<CatalogProvider>(
                  builder: (context, provider, child) =>
                      _buildCategoriesList(provider, isMobile),
                ),
              ),
            )
          : null,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const LogoWidget(size: 32),
              const SizedBox(width: 8),
              const Text(
                'Gadget World',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
              );
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar (Hidden on mobile)
          if (!isMobile)
            Container(
              width: 180,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: AppTheme.greyBorder)),
              ),
              child: Consumer<CatalogProvider>(
                builder: (context, provider, child) =>
                    _buildCategoriesList(provider, isMobile),
              ),
            ),

          // Right Content Area
          Expanded(
            child: Consumer<CatalogProvider>(
              builder: (context, provider, child) {
                final isLoading = provider.isLoadingProducts;
                final error = provider.productsError;
                final products = _selectedCategory == null
                    ? provider.products
                    : provider.currentCategoryProducts;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Area
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (isMobile)
                                      InkWell(
                                        onTap: () {
                                          if (Navigator.canPop(context)) {
                                            Navigator.pop(context);
                                          } else {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const MainScreen(
                                                      initialIndex: 0,
                                                    ),
                                              ),
                                              (route) => false,
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.greyBackground,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_back,
                                            size: 20,
                                            color: AppTheme.black,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      _selectedCategory == null
                                          ? 'All Products'
                                          : _selectedCategory!.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedCategory == null
                                ? 'Discover top quality gadgets across all categories.'
                                : 'Explore our collection of ${_selectedCategory!.name}.',
                            style: const TextStyle(
                              color: AppTheme.greyText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${products.length}+ Products Found',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Products Grid
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : error != null
                          ? Center(
                              child: Text(
                                'Error: $error',
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : products.isEmpty
                          ? const Center(
                              child: Text(
                                'No products available.',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 220,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
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
                                        builder: (_) => ProductDetailsScreen(
                                          product: product,
                                        ),
                                      ),
                                    );
                                  },
                                  onAdd: () {
                                    if (product.stockQuantity > 0) {
                                      context.read<CartProvider>().addToCart(
                                        product.id,
                                        1,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${product.name} added to cart',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Out of stock'),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
