import 'package:flutter/material.dart';
import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/core/widgets/primary_button.dart';
import 'package:gadget_world/features/checkout/screens/apply_coupon_screen.dart';
import 'package:gadget_world/features/checkout/screens/checkout_screen.dart';
import 'package:gadget_world/features/home/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/features/cart/providers/cart_provider.dart';
import 'package:gadget_world/features/cart/models/cart.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final formatCurrency = NumberFormat.simpleCurrency(
    name: 'INR',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  Widget _buildFreeShippingBar(double subtotal) {
    const double threshold = 5000;
    final double remaining = threshold - subtotal;
    final bool isFree = remaining <= 0;
    final double progress = (subtotal / threshold).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isFree
                      ? 'You have unlocked FREE shipping!'
                      : 'You\'re ${formatCurrency.format(remaining)} away from FREE shipping!',
                  style: const TextStyle(fontSize: 13, color: AppTheme.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.greyBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '₹0',
                style: TextStyle(fontSize: 11, color: AppTheme.greyText),
              ),
              const Text(
                '₹5,000',
                style: TextStyle(fontSize: 11, color: AppTheme.greyText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartProvider provider,
  ) {
    final product = item.product;
    if (product == null) return const SizedBox.shrink();

    final name = product['name'] ?? 'Unknown';
    final price = product['price'] != null
        ? (double.tryParse(product['price'].toString()) ?? 0.0)
        : 0.0;

    String? imageUrl;
    final images = product['images'];
    if (images is List && images.isNotEmpty) {
      imageUrl = images.first?.toString();
    } else if (images is String && images.isNotEmpty) {
      imageUrl = images;
      if (imageUrl.startsWith('{') && imageUrl.endsWith('}')) {
        imageUrl = imageUrl
            .substring(1, imageUrl.length - 1)
            .split(',')
            .first
            .replaceAll('"', '')
            .trim();
      }
    }

    final variantName = item.variant != null
        ? (item.variant!['name'] ?? item.variant!['variant_name'])
        : null;
    final stockQuantity = product['stock_quantity'] != null
        ? (int.tryParse(product['stock_quantity'].toString()) ?? 0)
        : 0;
    final bool hasStockWarning = item.quantity > stockQuantity;
    final int displayQuantity = item.quantity;
    final double totalPrice = price * displayQuantity;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.greyBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            PhosphorIcons.image,
                            color: AppTheme.greyText,
                          ),
                        ),
                      )
                    : const Icon(PhosphorIcons.image, color: AppTheme.greyText),
              ),
              const SizedBox(width: 16),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => provider.removeFromCart(item.id),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                    if (variantName != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Color: $variantName',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Stock badge
                    if (stockQuantity > 0 && !hasStockWarning)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'In Stock',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Only $stockQuantity left',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Stepper & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Stepper
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.greyBorder),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: displayQuantity > 1
                                    ? () => provider.updateQuantity(
                                        item.id,
                                        displayQuantity - 1,
                                      )
                                    : null,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: displayQuantity > 1
                                        ? AppTheme.black
                                        : AppTheme.greyText,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  '$displayQuantity',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => provider.updateQuantity(
                                  item.id,
                                  displayQuantity + 1,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Icon(PhosphorIcons.plus, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatCurrency.format(price),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (displayQuantity > 1)
                              Text(
                                '${formatCurrency.format(totalPrice)} ($displayQuantity units)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.greyText,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasStockWarning) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only $stockQuantity left in stock. Please reduce quantity.',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponSection(CartProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.greyBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.local_offer_outlined, color: AppTheme.black),
        title: Text(
          provider.appliedCouponCode != null
              ? 'Coupon Applied'
              : 'Have a coupon code?',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          provider.appliedCouponCode != null
              ? '${provider.appliedCouponCode} applied'
              : 'Apply code to get instant discount',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.black.withValues(alpha: 0.6),
          ),
        ),
        trailing: const Icon(PhosphorIcons.caretRight, size: 20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApplyCouponScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSummary(CartProvider provider) {
    final subtotal = provider.subtotal;
    final discount = provider.discount;
    final shipping = provider.shippingFee;
    final total = provider.total;
    final itemCount = provider.itemCount;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.greyBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal ($itemCount items)',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      formatCurrency.format(subtotal),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discount',
                        style: TextStyle(fontSize: 13, color: Colors.green),
                      ),
                      Text(
                        '- ${formatCurrency.format(discount)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Shipping Estimate',
                          style: TextStyle(fontSize: 13, color: AppTheme.black),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: AppTheme.greyText,
                        ),
                      ],
                    ),
                    Text(
                      formatCurrency.format(shipping),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppTheme.greyBorder),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'All prices are exclusive of GST',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatCurrency.format(total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              );
            },
            text: 'Proceed to Checkout',
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cart = cartProvider.cart;
        final items = cart?.items ?? [];
        final itemCount = cartProvider.itemCount;

        return Scaffold(
          backgroundColor: AppTheme.white,
          body: cartProvider.isLoading && items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : cartProvider.error != null
              ? Center(
                  child: Text(
                    'Error loading cart: ${cartProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        PhosphorIcons.shoppingCart,
                        size: 64,
                        color: AppTheme.greyText,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        text: 'Start Shopping',
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  24,
                                  16,
                                  8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: AppTheme.black,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text: 'Your Cart ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '($itemCount)',
                                                style: TextStyle(
                                                  color: AppTheme.greyText,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.verified_user_outlined,
                                              size: 16,
                                              color: AppTheme.black.withValues(
                                                alpha: 0.7,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '100% Secure',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.black
                                                    .withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Review your items and proceed to checkout',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.greyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildFreeShippingBar(cartProvider.subtotal),
                              ...items
                                  .map(
                                    (item) => _buildCartItem(
                                      context,
                                      item,
                                      cartProvider,
                                    ),
                                  )
                                  ,
                              _buildCouponSection(cartProvider),
                            ],
                          ),
                        ),
                      ),
                      _buildSummary(cartProvider),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
