import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../../features/products/models/product_model.dart';
import '../../features/more/providers/wishlist_provider.dart';

class ProductCard extends StatelessWidget {
  final String? productId;
  final String imageUrl;
  final String title;
  final String price;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const ProductCard({
    super.key,
    this.productId,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.onTap,
    required this.onAdd,
  });

  factory ProductCard.fromProduct({
    Key? key,
    required ProductModel product,
    required VoidCallback onTap,
    required VoidCallback onAdd,
  }) {
    return ProductCard(
      key: key,
      productId: product.id,
      imageUrl: product.imageUrl ?? 'assets/images/laptop.png',
      title: product.name,
      price: NumberFormat.simpleCurrency(
        name: 'INR',
        decimalDigits: 0,
      ).format(product.price),
      onTap: onTap,
      onAdd: onAdd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.greyBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.greyBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _ProductImage(imageUrl: imageUrl),
                    ),
                  ),
                  if (productId != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Consumer<WishlistProvider>(
                        builder: (context, provider, child) {
                          final isInWishlist = provider.isInWishlist(
                            productId!,
                          );
                          return GestureDetector(
                            onTap: () {
                              provider.toggleWishlist(productId!);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isInWishlist
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 20,
                                color: isInWishlist
                                    ? Colors.red
                                    : AppTheme.greyText,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
      );
    }
    return Image.asset(imageUrl, fit: BoxFit.cover);
  }
}
