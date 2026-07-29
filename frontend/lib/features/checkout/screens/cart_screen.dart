import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/primary_button.dart';
import 'package:gadget_store/features/checkout/screens/apply_coupon_screen.dart';
import 'package:gadget_store/features/checkout/screens/checkout_screen.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import 'package:gadget_store/features/cart/models/cart.dart';
import 'package:gadget_store/features/products/models/product_model.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cart = cartProvider.cart;
        final items = cart?.items ?? [];
        final itemCount = cartProvider.itemCount;

        double subtotal = 0;
        for (var item in items) {
          final price = item.product?['price'] != null
              ? (double.tryParse(item.product!['price'].toString()) ?? 0.0)
              : 0.0;
          subtotal += price * item.quantity;
        }

        double discount = 0; // Static for now, can implement coupons later
        double shipping = subtotal > 50000 ? 0 : 299;
        if (items.isEmpty) shipping = 0;
        double total = subtotal - discount + shipping;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Your Cart ($itemCount)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: AppTheme.black.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '100% Secure',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.black.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: cartProvider.isLoading && items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : cartProvider.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      'Error loading cart: ${cartProvider.error}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : items.isEmpty
              ? _buildEmptyCart()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Review your items and proceed to checkout',
                            style: TextStyle(
                              color: AppTheme.greyText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFreeShippingProgress(subtotal),
                      const SizedBox(height: 16),
                      // List of items
                      ...items.map(
                        (item) => _buildCartItem(context, item, cartProvider),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ApplyCouponScreen(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.greyBorder),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_offer_outlined,
                                color: AppTheme.black,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Have a coupon code?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Apply code to get instant discount',
                                      style: TextStyle(
                                        color: AppTheme.greyText,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: AppTheme.black,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: AppTheme.greyBackground.withValues(alpha: 0.5),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              'Subtotal ($itemCount items)',
                              formatCurrency.format(subtotal),
                            ),
                            const SizedBox(height: 8),
                            if (discount > 0) ...[
                              _buildPriceRow(
                                'Discount',
                                '- ${formatCurrency.format(discount)}',
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Shipping Estimate',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.info_outline,
                                      size: 12,
                                      color: AppTheme.greyText,
                                    ),
                                  ],
                                ),
                                Text(
                                  shipping == 0
                                      ? 'FREE'
                                      : formatCurrency.format(shipping),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(
                                color: AppTheme.greyBorder,
                                height: 1,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 2),
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
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              text: 'Proceed to Checkout',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppTheme.greyBorder,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeShippingProgress(double subtotal) {
    const target = 50000.0;
    final value = (subtotal / target).clamp(0.0, 1.0);
    final remaining = (target - subtotal).clamp(0.0, target);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value >= 1
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value >= 1
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              color: value >= 1 ? Colors.green : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: AppTheme.black, fontSize: 12),
                    children: [
                      if (value >= 1)
                        const TextSpan(text: 'You have FREE shipping!')
                      else ...[
                        const TextSpan(text: 'You\'re '),
                        TextSpan(
                          text: formatCurrency.format(remaining),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' away from FREE shipping!'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: value,
                  backgroundColor: AppTheme.greyBorder,
                  color: value >= 1 ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatCurrency.format(0),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.greyText,
                      ),
                    ),
                    Text(
                      formatCurrency.format(target),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.greyText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItem item,
    CartProvider cartProvider,
  ) {
    final title = item.product?['name'] as String? ?? 'Unknown Product';
    final price = item.product?['price'] != null
        ? (double.tryParse(item.product!['price'].toString()) ?? 0.0)
        : 0.0;
    final totalPrice = price * item.quantity;
    final moq = (item.product?['moq'] as int?) ?? 1;

    // Attempt to extract variation details
    final variantName = item.variant?['name'] as String?;
    final color = variantName ?? 'Default';

    final isWarning = item.quantity < moq;
    final errorMessage = isWarning
        ? 'Minimum order is $moq units. Add ${moq - item.quantity} more unit to proceed.'
        : null;

    return GestureDetector(
      onTap: () {
        if (item.product != null) {
          final productModel = ProductModel.fromJson(item.product!);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: productModel),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.greyBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        item.product?['images'] != null &&
                            (item.product?['images'] as List).isNotEmpty
                        ? Image.network(
                            (item.product?['images'] as List).first as String,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          )
                        : Image.asset(
                            'assets/images/phone.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => cartProvider.removeFromCart(item.id),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Variant: $color',
                        style: const TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.greyBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MOQ: $moq',
                              style: const TextStyle(fontSize: 8),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 24,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.greyBorder),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (item.quantity > 1) {
                                      cartProvider.updateQuantity(
                                        item.id,
                                        item.quantity - 1,
                                      );
                                    } else {
                                      cartProvider.removeFromCart(item.id);
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Icon(Icons.remove, size: 12),
                                  ),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => cartProvider.updateQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Icon(Icons.add, size: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    formatCurrency.format(price),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${formatCurrency.format(totalPrice)} (${item.quantity} units)',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.greyText,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.error,
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color color = AppTheme.black,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
