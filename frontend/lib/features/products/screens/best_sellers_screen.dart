import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import '../models/product_model.dart';
import '../providers/catalog_provider.dart';
import 'product_details_screen.dart';

class BestSellersScreen extends StatefulWidget {
  const BestSellersScreen({super.key});

  @override
  State<BestSellersScreen> createState() => _BestSellersScreenState();
}

class _BestSellersScreenState extends State<BestSellersScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Best Sellers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingFeatured) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.featuredError != null) {
            return _StateMessage(message: provider.featuredError!);
          }
          if (provider.featuredProducts.isEmpty) {
            return const _StateMessage(
              message: 'No featured products available.',
            );
          }
          return _ProductGrid(products: provider.featuredProducts);
        },
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<ProductModel> products;

  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
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
          onAdd: () {},
        );
      },
    );
  }
}

class _StateMessage extends StatelessWidget {
  final String message;

  const _StateMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.greyText),
        ),
      ),
    );
  }
}
