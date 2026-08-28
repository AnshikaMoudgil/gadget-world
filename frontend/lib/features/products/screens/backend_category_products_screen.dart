import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gadget_store/core/widgets/product_card.dart';
import '../models/category_model.dart';
import '../providers/catalog_provider.dart';
import 'product_details_screen.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class BackendCategoryProductsScreen extends StatefulWidget {
  final String title;
  final List<String> categorySlugs;

  const BackendCategoryProductsScreen({
    super.key,
    required this.title,
    required this.categorySlugs,
  });

  @override
  State<BackendCategoryProductsScreen> createState() =>
      _BackendCategoryProductsScreenState();
}

class _BackendCategoryProductsScreenState
    extends State<BackendCategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  Future<void> _loadProducts() async {
    final provider = Provider.of<CatalogProvider>(context, listen: false);
    await provider.fetchCategories();
    if (!mounted) return;
    CategoryModel? category;
    for (final slug in widget.categorySlugs) {
      for (final candidate in provider.categories) {
        if (candidate.slug == slug) {
          category = candidate;
          break;
        }
      }
      if (category != null) break;
    }
    if (category != null) {
      await provider.fetchProductsByCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingCategories || provider.isLoadingProducts) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.categoriesError != null ||
              provider.productsError != null) {
            return Center(
              child: Text(provider.productsError ?? provider.categoriesError!),
            );
          }
          final products = provider.currentCategoryProducts;
          if (products.isEmpty) {
            return const Center(child: Text('No products available.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.orientationOf(context) == Orientation.landscape
                  ? 4
                  : 2,
              childAspectRatio:
                  MediaQuery.orientationOf(context) == Orientation.landscape
                  ? 0.9
                  : 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard.fromProduct(
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
              );
            },
          );
        },
      ),
    );
  }
}
