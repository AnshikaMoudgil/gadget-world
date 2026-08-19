import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/home/widgets/promo_banner.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import 'package:gadget_store/features/products/screens/search_results_screen.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';
import 'package:gadget_store/features/products/screens/best_sellers_screen.dart';
import 'package:gadget_store/features/products/screens/new_arrivals_screen.dart';
import 'package:gadget_store/features/products/screens/featured_products_screen.dart';
import 'package:gadget_store/features/products/screens/categories_screen.dart';
import 'package:gadget_store/features/products/screens/products_by_category_screen.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/features/products/providers/catalog_provider.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CatalogProvider>(context, listen: false);
      provider.fetchCategories(forceRefresh: true);
      provider.fetchProducts(forceRefresh: true);
      provider.fetchFeaturedProducts(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const LogoWidget(size: 32),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 18, color: AppTheme.black),
                  children: [
                    TextSpan(
                      text: 'Gadget ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'World',
                      style: TextStyle(fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.greyBorder),
                ),
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchResultsScreen(),
                      ),
                    );
                  },
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search for products, brands and more...',
                    hintStyle: const TextStyle(
                      color: AppTheme.greyText,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    prefixIcon: const Icon(
                      PhosphorIcons.magnifyingGlass,
                      color: AppTheme.greyText,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.tune),
                      color: AppTheme.greyText,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => const FilterBottomSheet(),
                        );
                      },
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
            Consumer<CatalogProvider>(
              builder: (context, provider, child) {
                if (!provider.hasActiveFilters) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'After applying filters',
                        style: TextStyle(
                          color: AppTheme.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (provider.minPrice != null ||
                                provider.maxPrice != null)
                              _buildActiveFilterChip(
                                '₹${provider.minPrice?.toInt() ?? 0} - ₹${provider.maxPrice?.toInt() ?? '20,000+'}',
                                () => provider.setFilters(
                                  brandId: provider.filterBrandId,
                                  inStock: provider.inStock,
                                  sortBy: provider.sortBy,
                                ),
                              ),
                            if (provider.filterBrandId != null)
                              _buildActiveFilterChip(
                                provider.filterBrandId!,
                                () => provider.setFilters(
                                  minPrice: provider.minPrice,
                                  maxPrice: provider.maxPrice,
                                  inStock: provider.inStock,
                                  sortBy: provider.sortBy,
                                ),
                              ),
                            if (provider.inStock != null)
                              _buildActiveFilterChip(
                                provider.inStock! ? 'In Stock' : 'Out of Stock',
                                () => provider.setFilters(
                                  minPrice: provider.minPrice,
                                  maxPrice: provider.maxPrice,
                                  brandId: provider.filterBrandId,
                                  sortBy: provider.sortBy,
                                ),
                              ),
                            if (provider.sortBy != null)
                              _buildActiveFilterChip(
                                'Sort: ${provider.sortBy}',
                                () => provider.setFilters(
                                  minPrice: provider.minPrice,
                                  maxPrice: provider.maxPrice,
                                  brandId: provider.filterBrandId,
                                  inStock: provider.inStock,
                                ),
                              ),
                            TextButton(
                              onPressed: provider.clearFilters,
                              child: const Text(
                                'Clear All',
                                style: TextStyle(
                                  color: AppTheme.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
            const PromoBannerSlider(),
            const SizedBox(height: 24),
            _buildCategories(),
            const SizedBox(height: 8),
            _buildSectionHeader(
              'Best Sellers',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BestSellersScreen()),
                );
              },
            ),
            _buildHorizontalProductList(badgeText: 'Bestseller'),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'New Arrivals',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewArrivalsScreen()),
                );
              },
            ),
            _buildHorizontalProductList(badgeText: 'New'),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'Featured Products',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FeaturedProductsScreen(),
                  ),
                );
              },
            ),
            _buildHorizontalProductList(
              isFeatured: true,
              discountText: '2% OFF',
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.greyBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      PhosphorIcons.shoppingBag,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No products available',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'We\'re working on adding amazing products.\nPlease check back later.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 12),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Consumer<CatalogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCategories) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final categories = provider.categories.toList();

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              'Categories',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),
            SizedBox(
              height: 90,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  IconData getCategoryIcon(String name) {
                    final n = name.toLowerCase();
                    if (n.contains('mobile') || n.contains('phone')) {
                      return CupertinoIcons.device_phone_portrait;
                    }
                    if (n.contains('laptop') ||
                        n.contains('tablet') ||
                        n.contains('computer')) {
                      return CupertinoIcons.device_laptop;
                    }
                    if (n.contains('audio') ||
                        n.contains('earphone') ||
                        n.contains('headphone')) {
                      return CupertinoIcons.headphones;
                    }
                    if (n.contains('wearable') || n.contains('watch')) {
                      return CupertinoIcons.time;
                    }
                    if (n.contains('cable') || n.contains('charger')) {
                      return CupertinoIcons.bolt_horizontal;
                    }
                    if (n.contains('camera')) return CupertinoIcons.camera;
                    if (n.contains('gaming') || n.contains('game')) {
                      return CupertinoIcons.game_controller;
                    }
                    return CupertinoIcons.circle_grid_3x3;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductsByCategoryScreen(category: category),
                        ),
                      );
                    },
                    child: Container(
                      width: 64,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.greyBorder,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: category.imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        category.imageUrl!,
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      getCategoryIcon(category.name),
                                      size: 24,
                                      color: AppTheme.black,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.black,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHorizontalProductList({
    bool isFeatured = false,
    String? badgeText,
    String? discountText,
  }) {
    return Consumer<CatalogProvider>(
      builder: (context, provider, child) {
        final isLoading = isFeatured
            ? provider.isLoadingFeatured
            : provider.isLoadingProducts;
        final error = isFeatured
            ? provider.featuredError
            : provider.productsError;
        final products = isFeatured
            ? provider.featuredProducts.take(6).toList()
            : provider.products.take(6).toList();

        if (isLoading) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (error != null) {
          return SizedBox(
            height: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Failed to load products',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => isFeatured
                        ? provider.fetchFeaturedProducts(forceRefresh: true)
                        : provider.fetchProducts(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (products.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(child: Text('No products available.')),
          );
        }

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ProductCard.fromProduct(
                    product: product,
                    badgeText: badgeText,
                    discountText: discountText,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    ),
                    onAdd: () {
                      if (product.stockQuantity > 0) {
                        context.read<CartProvider>().addToCart(product.id, 1);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Out of stock'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onDeleted) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.greyBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.black),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(Icons.close, size: 14, color: AppTheme.black),
          ),
        ],
      ),
    );
  }
}
