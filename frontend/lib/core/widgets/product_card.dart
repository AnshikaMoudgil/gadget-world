import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../../features/products/models/product_model.dart';
import '../../features/more/providers/wishlist_provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ProductCard extends StatelessWidget {
  final String? productId;
  final String imageUrl;
  final String title;
  final String price;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final String? badgeText;
  final String? discountText;
  final String? moqText;
  final String? stockStatus;
  final Color? stockStatusColor;

  const ProductCard({
    super.key,
    this.productId,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.onTap,
    required this.onAdd,
    this.badgeText,
    this.discountText,
    this.moqText,
    this.stockStatus,
    this.stockStatusColor,
  });

  factory ProductCard.fromProduct({
    Key? key,
    required ProductModel product,
    required VoidCallback onTap,
    required VoidCallback onAdd,
    String? badgeText,
    String? discountText,
    String? moqText,
    bool showStockStatus = false,
  }) {
    String? stockStatus;
    Color? stockColor;
    if (showStockStatus) {
      if (product.stockQuantity > 10) {
        stockStatus = 'In Stock';
        stockColor = Colors.green;
      } else if (product.stockQuantity > 0) {
        stockStatus = 'Low Stock (${product.stockQuantity} left)';
        stockColor = Colors.orange;
      } else {
        stockStatus = 'Out of Stock';
        stockColor = Colors.red;
      }
    }

    return ProductCard(
      key: key ?? ValueKey(product.id),
      productId: product.id,
      imageUrl: product.imageUrl ?? 'assets/images/laptop.png',
      title: product.name,
      price: NumberFormat.simpleCurrency(
        name: 'INR',
        decimalDigits: 0,
      ).format(product.price),
      onTap: onTap,
      onAdd: onAdd,
      badgeText: badgeText,
      discountText: discountText,
      moqText: moqText,
      stockStatus: stockStatus,
      stockStatusColor: stockColor,
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
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Center(child: _ProductImage(imageUrl: imageUrl)),
                    ),
                  ),

                  if (productId != null)
                    Positioned(
                      top: 0,
                      right: 0,
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
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isInWishlist
                                    ? CupertinoIcons.heart_fill
                                    : CupertinoIcons.heart,
                                size: 18, // slightly larger for cupertino
                                color: isInWishlist
                                    ? Colors.red
                                    : AppTheme.black,
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              price,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            '/ piece',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                      if (discountText != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.greyBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            discountText!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.black,
                            ),
                          ),
                        ),
                      ],
                      if (moqText != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.greyBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            moqText!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.black,
                            ),
                          ),
                        ),
                      ],
                      if (stockStatus != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          stockStatus!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: stockStatusColor ?? Colors.green,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Icon(PhosphorIcons.image),
      );
    }
    return Image.asset(imageUrl, fit: BoxFit.contain);
  }
}
