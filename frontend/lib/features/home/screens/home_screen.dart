import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import 'package:gadget_store/features/products/screens/search_results_screen.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';
import 'package:gadget_store/features/products/screens/best_sellers_screen.dart';
import 'package:gadget_store/features/products/screens/new_arrivals_screen.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/features/products/providers/catalog_provider.dart';
import 'package:gadget_store/features/products/screens/products_by_category_screen.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import '../widgets/filter_bottom_sheet.dart';

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
                      Icons.search,
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
            _buildPromoBanner(),
            const SizedBox(height: 24),
            _buildFeatureTabs(),
            const SizedBox(height: 24),
            _buildSectionHeader(
              'Best Sellers',
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BestSellersScreen()),
                );
              },
            ),
            _buildHorizontalProductList(),
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
            _buildHorizontalProductList(),
            const SizedBox(height: 24),
            _buildSectionHeader('Featured Products'),
            _buildHorizontalProductList(isFeatured: true),
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
                      Icons.shopping_bag_outlined,
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
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

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF3F0FF),
            Color(0xFFE5E9FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.black,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: 'Upgrade Your\n'),
                      TextSpan(
                        text: 'Tech ',
                        style: TextStyle(color: Color(0xFF5A5DF0)),
                      ),
                      TextSpan(text: 'Game'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Discover the latest gadgets\nand innovative tech products.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1B2F),
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1B2F),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.greyBorder,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Consumer<CatalogProvider>(
              builder: (context, provider, child) {
                final products = provider.products;
                if (products.length >= 2) {
                  return SizedBox(
                    width: 200,
                    height: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          right: 0,
                          bottom: 40,
                          child: Transform.rotate(
                            angle: 0.2,
                            child: SizedBox(
                              width: 110,
                              height: 110,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  products[1].images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 80,
                          bottom: 10,
                          child: Transform.rotate(
                            angle: -0.1,
                            child: SizedBox(
                              width: 130,
                              height: 130,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  products[0].images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.devices_other,
                        size: 80,
                        color: const Color(0xFF5A5DF0).withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureItem(
            icon: Icons.verified_user_outlined,
            title: 'Secure\nPayments',
            subtitle: '100% secure',
          ),
          _buildFeatureDivider(),
          _buildFeatureItem(
            icon: Icons.local_shipping_outlined,
            title: 'Free\nDelivery',
            subtitle: 'Above ₹999',
          ),
          _buildFeatureDivider(),
          _buildFeatureItem(
            icon: Icons.replay,
            title: 'Easy\nReturns',
            subtitle: '7-day return',
          ),
          _buildFeatureDivider(),
          _buildFeatureItem(
            icon: Icons.support_agent,
            title: '24/7\nSupport',
            subtitle: "We're here to help",
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF5A5DF0), size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.greyBorder.withValues(alpha: 0.3),
    );
  }

  Widget _buildHorizontalProductList({bool isFeatured = false}) {
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
            height: 260,
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
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 160,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ProductCard.fromProduct(
                    product: product,
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
