import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gadget_store/core/theme.dart';
import '../models/product_model.dart';
import '../providers/catalog_provider.dart';
import '../../cart/providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gadget_store/features/checkout/screens/cart_screen.dart';
import 'package:gadget_store/features/more/providers/wishlist_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  late ProductModel _product;
  int _selectedImageIndex = 0;
  bool _isLoadingDetails = true;
  String? _detailError;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetails());
  }

  Future<void> _loadDetails() async {
    final result = await context.read<CatalogProvider>().fetchProductBySlug(
      widget.product.slug,
    );
    if (!mounted) return;
    setState(() {
      _isLoadingDetails = false;
      _detailError = result == null
          ? context.read<CatalogProvider>().productError
          : null;
      if (result != null) {
        _product = result;
        _selectedImageIndex = 0;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _product.images.isEmpty
        ? const ['assets/images/phone.png']
        : _product.images;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () async {
              final formatCurrency = NumberFormat.simpleCurrency(
                name: 'INR',
                decimalDigits: 0,
              );
              // ignore: deprecated_member_use
              await Share.share(
                'Check out ${_product.name} for ${formatCurrency.format(_product.price)} at Gadget World!',
              );
            },
          ),
          Consumer<WishlistProvider>(
            builder: (context, provider, child) {
              final isInWishlist = provider.isInWishlist(_product.id);
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : null,
                ),
                onPressed: () {
                  provider.toggleWishlist(_product.id);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Gallery(
              images: images,
              controller: _pageController,
              selectedIndex: _selectedImageIndex,
              onPageChanged: (index) =>
                  setState(() => _selectedImageIndex = index),
              onThumbnailSelected: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoadingDetails)
                    const LinearProgressIndicator(minHeight: 2),
                  if (_detailError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Some product details could not be loaded.',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (_product.brandName != null) ...[
                    Text(
                      _product.brandName!,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_product.categoryName != null)
                      Text(
                        _product.categoryName!,
                        style: const TextStyle(color: AppTheme.greyText),
                      ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        NumberFormat.simpleCurrency(
                          name: 'INR',
                          decimalDigits: 0,
                        ).format(_product.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_product.mrp != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          NumberFormat.simpleCurrency(
                            name: 'INR',
                            decimalDigits: 0,
                          ).format(_product.mrp),
                          style: const TextStyle(
                            color: AppTheme.greyText,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StockBadge(product: _product),
                  if (_product.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 24),
                    const _SectionTitle('Description'),
                    const SizedBox(height: 8),
                    Text(
                      _product.description!,
                      style: const TextStyle(
                        color: AppTheme.greyText,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (_product.aboutPoints.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionTitle('Highlights'),
                    const SizedBox(height: 8),
                    ..._product.aboutPoints.map(
                      (point) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(point)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_product.specs.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionTitle('Specifications'),
                    const SizedBox(height: 8),
                    ..._product.specs.map(
                      (spec) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                spec.key,
                                style: const TextStyle(
                                  color: AppTheme.greyText,
                                ),
                              ),
                            ),
                            Expanded(child: Text(spec.value)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_product.features.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionTitle('Features'),
                    const SizedBox(height: 8),
                    ..._product.features.map(
                      (feature) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        title: Text(feature.title),
                        subtitle: feature.description.isEmpty
                            ? null
                            : Text(feature.description),
                      ),
                    ),
                  ],
                  if (_product.variants.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const _SectionTitle('Available variants'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _product.variants
                          .map((variant) => Chip(label: Text(variant.name)))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      SizedBox(
                        height: 52,
                        width: 52,
                        child: OutlinedButton(
                          onPressed: _product.stockQuantity > 0
                              ? () async {
                                  context.read<CartProvider>().addToCart(
                                    _product.id,
                                    1,
                                  );

                                  _showAddedToCartPopup(context);
                                }
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            side: const BorderSide(
                              color: AppTheme.black,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: AppTheme.black,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _product.stockQuantity > 0
                                ? () async {
                                    final nav = Navigator.of(context);
                                    await context
                                        .read<CartProvider>()
                                        .addToCart(_product.id, 1);
                                    if (mounted) {
                                      nav.push(
                                        MaterialPageRoute(
                                          builder: (_) => const CartScreen(),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.black,
                              foregroundColor: AppTheme.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddedToCartPopup(BuildContext context) {
    if (context.read<CartProvider>().error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: SelectableText('DEBUG ADD ERROR: ${context.read<CartProvider>().error}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 10),
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppTheme.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Added to Cart!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: AppTheme.greyBackground,
                      child:
                          _product.imageUrl != null &&
                              _product.imageUrl!.isNotEmpty
                          ? Image.network(
                              _product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.image_outlined),
                            )
                          : const Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.simpleCurrency(
                            name: 'INR',
                            decimalDigits: 0,
                          ).format(_product.price),
                          style: const TextStyle(color: AppTheme.greyText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Cart & Checkout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(color: AppTheme.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Gallery extends StatelessWidget {
  final List<String> images;
  final PageController controller;
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailSelected;

  const _Gallery({
    required this.images,
    required this.controller,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.onThumbnailSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) => Container(
              color: AppTheme.greyBackground,
              padding: const EdgeInsets.all(24),
              child: _ProductImage(imageUrl: images[index]),
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 68,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) => InkWell(
                onTap: () => onThumbnailSelected(index),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 68,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedIndex == index
                          ? AppTheme.black
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _ProductImage(imageUrl: images[index]),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );
}

class _StockBadge extends StatelessWidget {
  final ProductModel product;

  const _StockBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    final inStock = product.stockQuantity > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: (inStock ? Colors.green : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        inStock ? '${product.stockQuantity} units available' : 'Out of stock',
        style: TextStyle(
          color: inStock ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
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
        errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
      );
    }
    return Image.asset(imageUrl, fit: BoxFit.contain);
  }
}
