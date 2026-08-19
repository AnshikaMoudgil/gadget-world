import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import '../models/product_model.dart';
import '../providers/catalog_provider.dart';
import 'product_details_screen.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import 'package:gadget_store/features/checkout/screens/cart_screen.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class NewArrivalsScreen extends StatefulWidget {
  const NewArrivalsScreen({super.key});

  @override
  State<NewArrivalsScreen> createState() => _NewArrivalsScreenState();
}

class _NewArrivalsScreenState extends State<NewArrivalsScreen> {
  String _selectedSort = 'Popular';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CatalogProvider>(
        context,
        listen: false,
      ).fetchFeaturedProducts();
    });
  }

  List<ProductModel> _getSortedProducts(List<ProductModel> products) {
    List<ProductModel> sorted = List.from(products);
    if (_selectedSort == 'Price: Low to High') {
      sorted.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Price: High to Low') {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    }
    // 'Popular' is the default fetched order
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final itemCount = cartProvider.itemCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      PhosphorIcons.shoppingCart,
                      color: AppTheme.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.black,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: AppTheme.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          final sortedProducts = _getSortedProducts(provider.products);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Arrivals',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Top rated and most purchased gadgets',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!provider.isLoadingFeatured &&
                          provider.products.isNotEmpty)
                        _buildSortDropdown(),
                    ],
                  ),
                ),
              ),
              if (provider.isLoadingFeatured)
                _buildLoadingGrid()
              else if (provider.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final product = sortedProducts[index];
                      return ProductCard.fromProduct(
                        product: product,
                        badgeText: 'New',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(product: product),
                          ),
                        ),
                        onAdd: () {
                          if (product.stockQuantity > 0) {
                            context.read<CartProvider>().addToCart(
                              product.id,
                              1,
                            );
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
                      );
                    }, childCount: sortedProducts.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_outlined, size: 20, color: AppTheme.black),
          const SizedBox(width: 8),
          const Text(
            'Sort by:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSort,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.black,
                ),
                items: ['Popular', 'Price: Low to High', 'Price: High to Low']
                    .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    })
                    .toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedSort = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.greyBackground.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.greyBackground.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.greyBackground.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 16,
                              width: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.greyBackground.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                color: AppTheme.greyBackground.withValues(
                                  alpha: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }, childCount: 6),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          // Graphic
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.greyBackground.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                Icons.inventory_2_outlined,
                size: 80,
                color: AppTheme.greyBorder,
              ),
              const Positioned(top: 40, child: LogoWidget(size: 32)),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'No new arrivals yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We're working on bringing you the\nbest gadgets.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.greyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Check back soon!',
            style: TextStyle(fontSize: 14, color: AppTheme.greyText),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Explore All Products',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(PhosphorIcons.arrowRight, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
