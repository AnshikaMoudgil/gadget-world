import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';
import '../models/category_model.dart';
import '../providers/catalog_provider.dart';

class ProductsByCategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const ProductsByCategoryScreen({super.key, required this.category});

  @override
  State<ProductsByCategoryScreen> createState() =>
      _ProductsByCategoryScreenState();
}

class _ProductsByCategoryScreenState extends State<ProductsByCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CatalogProvider>(
        context,
        listen: false,
      ).fetchProductsByCategory(widget.category.id);
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
        title: Text(
          widget.category.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingProducts) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.productsError != null) {
            return Center(
              child: Text(
                'Error: ${provider.productsError}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final products = provider.currentCategoryProducts;

          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products available in this category.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 14,
                      ),
                      children: [
                        const TextSpan(text: 'Showing products for '),
                        TextSpan(
                          text: '"${widget.category.name}"',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' (${products.length} results)',
                          style: const TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
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
                      onAdd: () {},
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
