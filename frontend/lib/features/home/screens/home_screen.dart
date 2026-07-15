import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/features/products/screens/search_results_screen.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';
import 'package:gadget_store/features/products/screens/best_sellers_screen.dart';
import 'package:gadget_store/features/products/screens/new_arrivals_screen.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/features/products/providers/catalog_provider.dart';
import 'package:gadget_store/features/products/screens/products_by_category_screen.dart';

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
      Provider.of<CatalogProvider>(context, listen: false).fetchCategories();
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
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.greyBorder),
                  ),
                  child: const TextField(
                    enabled: false,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search for products, brands and more...',
                      hintStyle: TextStyle(
                        color: AppTheme.greyText,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: AppTheme.greyText),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      suffixIcon: Icon(
                        Icons.center_focus_weak,
                        color: AppTheme.greyText,
                      ),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),
            ),
            _buildSectionHeader('Shop by Category'),
            _buildCategories(),
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
            _buildHorizontalProductList(),
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

  Widget _buildCategories() {
    return Consumer<CatalogProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingCategories) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final categories = provider.categories;

        if (categories.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(child: Text('No categories available.')),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.greyBorder),
                        ),
                        child: category.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  category.imageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.category_outlined, size: 32),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 72,
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHorizontalProductList() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductDetailsScreen()),
              );
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.greyBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.greyBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/laptop.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Bestseller',
                            style: TextStyle(
                              color: AppTheme.white,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(
                          Icons.favorite_border,
                          size: 20,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Product Name Example Very Long',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'â‚¹999',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppTheme.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
