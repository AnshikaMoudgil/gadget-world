import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/features/checkout/screens/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/features/cart/providers/cart_provider.dart';
import 'package:gadget_world/features/profile/providers/address_provider.dart';
import 'package:gadget_world/features/profile/screens/address_screen.dart';
import 'package:gadget_world/features/profile/models/address.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum CheckoutState { normal, priceChange, processing }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CheckoutState _currentState = CheckoutState.normal;

  void _cycleState() {
    setState(() {
      if (_currentState == CheckoutState.normal) {
        _currentState = CheckoutState.priceChange;
      } else if (_currentState == CheckoutState.priceChange) {
        _currentState = CheckoutState.processing;
      } else {
        _currentState = CheckoutState.normal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppTheme.white,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.change_circle_outlined,
              color: AppTheme.greyText,
            ),
            onPressed: _cycleState,
            tooltip: 'Cycle UI State',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 150,
            ), // Leave space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (_currentState == CheckoutState.priceChange)
                  _buildPriceChangeWarning(),
                _buildSectionTitle(
                  '1. Shipping Address',
                  true,
                  onChange: () async {
                    final selected = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddressScreen(isCheckout: true),
                      ),
                    );
                    if (selected != null && mounted) {
                      try {
                        await Provider.of<AddressProvider>(
                          context,
                          listen: false,
                        ).setDefaultAddress((selected as Address).id!);
                      } catch (_) {}
                    }
                  },
                ),
                _buildShippingAddress(),
                _buildSectionTitle('2. Order Summary', false),
                _buildOrderSummary(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Divider(
                    color: AppTheme.greyBorder.withValues(alpha: 0.5),
                    height: 32,
                  ),
                ),
                _buildCostSummary(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Divider(
                    color: AppTheme.greyBorder.withValues(alpha: 0.5),
                    height: 32,
                  ),
                ),
                _buildTotalAmount(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildBottomBar()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Review Your Order',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please review your order details before placing',
                  style: TextStyle(fontSize: 14, color: AppTheme.greyText),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 54,
                  color: AppTheme.greyText,
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppTheme.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceChangeWarning() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.red.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Change Detected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Some prices have changed since you last reviewed your cart.',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
          Text(
            'View details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
    bool showChangeBtn, {
    VoidCallback? onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.black,
            ),
          ),
          if (showChangeBtn)
            InkWell(
              onTap: onChange,
              child: const Text(
                'Change',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  color: AppTheme.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShippingAddress() {
    final addressProvider = Provider.of<AddressProvider>(context);
    final address = addressProvider.defaultAddress;

    if (address == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No address selected. Please add an address to proceed.',
          style: TextStyle(color: AppTheme.greyText, fontSize: 14),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: AppTheme.black, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.recipientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.black,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.black,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${address.addressLine1}, ${address.addressLine2 != null ? '${address.addressLine2}, ' : ''}\n${address.city}, ${address.state} - ${address.postalCode}',
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  address.phoneNumber,
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final cart = Provider.of<CartProvider>(context).cart;
    if (cart == null || cart.items.isEmpty) return const SizedBox();

    final formatCurrency = NumberFormat.simpleCurrency(
      name: 'INR',
      decimalDigits: 0,
    );

    return Column(
      children: [
        for (int i = 0; i < cart.items.length; i++) ...[
          Builder(
            builder: (context) {
              final item = cart.items[i];
              final product = item.product;
              final variantName = item.variant?['name'] as String? ?? 'Default';
              final price = product?['price'] != null
                  ? (double.tryParse(product!['price'].toString()) ?? 0.0)
                  : 0.0;
              final oldPrice = price + (price * 0.1);

              String? firstImageUrl;
              if (product != null) {
                dynamic imagesData = product['images'];
                if (imagesData is List && imagesData.isNotEmpty) {
                  firstImageUrl = imagesData[0].toString();
                } else if (imagesData is String && imagesData.isNotEmpty) {
                  try {
                    final parsed = jsonDecode(imagesData);
                    if (parsed is List && parsed.isNotEmpty) {
                      firstImageUrl = parsed[0].toString();
                    }
                  } catch (_) {}
                }
              }

              return _buildOrderItem(
                title: product?['name'] as String? ?? 'Unknown Product',
                color: variantName,
                qty: item.quantity,
                price: formatCurrency.format(price),
                hasPriceChange: _currentState == CheckoutState.priceChange,
                newPrice: formatCurrency.format(oldPrice),
                priceDiff: '↑ ${formatCurrency.format(oldPrice - price)}',
                imageUrl: firstImageUrl,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOrderItem({
    required String title,
    required String color,
    required int qty,
    required String price,
    String? newPrice,
    String? priceDiff,
    String? subtitle,
    bool hasPriceChange = false,
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.white, // No grey background in target
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      PhosphorIcons.shoppingBag,
                      color: AppTheme.greyText,
                      size: 32,
                    ),
                  )
                : const Icon(
                    PhosphorIcons.shoppingBag,
                    color: AppTheme.greyText,
                    size: 32,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  color,
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Qty: $qty',
                  style: const TextStyle(color: AppTheme.black, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasPriceChange ? newPrice! : price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.black,
                ),
              ),
              if (subtitle != null && !hasPriceChange)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.greyText,
                      fontSize: 12,
                    ),
                  ),
                ),
              if (hasPriceChange)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        priceDiff!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    final cartProvider = Provider.of<CartProvider>(context);
    final itemCount = cartProvider.itemCount;

    final subtotal = cartProvider.subtotal;
    final discount = cartProvider.discount;
    final shipping = cartProvider.shippingFee;

    // Attempting to pull coupon code if available
    final String appliedCoupon = cartProvider.appliedCouponCode != null
        ? ' (${cartProvider.appliedCouponCode})'
        : '';

    final formatCurrency = NumberFormat.simpleCurrency(
      name: 'INR',
      decimalDigits: 0,
    );
    final isChange = _currentState == CheckoutState.priceChange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          _buildCostRow(
            'Subtotal ($itemCount items)',
            formatCurrency.format(subtotal),
            isChange ? 'Was ${formatCurrency.format(subtotal * 0.9)}' : null,
          ),
          const SizedBox(height: 12),
          _buildCostRow(
            'Coupon Discount$appliedCoupon',
            '-${formatCurrency.format(discount)}',
            isChange ? 'Was -${formatCurrency.format(discount * 0.9)}' : null,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildCostRow(
            'Shipping Fee',
            shipping == 0 ? 'FREE' : formatCurrency.format(shipping),
            isChange ? 'No change' : null,
            showInfoIcon: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    String label,
    String value,
    String? oldVal, {
    Color color = AppTheme.black,
    bool showInfoIcon = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color == Colors.green ? Colors.green : AppTheme.greyText,
              ),
            ),
            if (showInfoIcon) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppTheme.greyText,
              ),
            ],
          ],
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            if (oldVal != null) ...[
              const SizedBox(width: 16),
              SizedBox(
                width: 75,
                child: Text(
                  oldVal,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    final cartProvider = Provider.of<CartProvider>(context);

    final discount = cartProvider.discount;
    final total = cartProvider.total;

    final formatCurrency = NumberFormat.simpleCurrency(
      name: 'INR',
      decimalDigits: 0,
    );
    final isChange = _currentState == CheckoutState.priceChange;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isChange ? 16 : 0),
            decoration: isChange
                ? BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChange ? 'New Total Amount' : 'Total Amount',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '(Inclusive of all taxes)',
                      style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency.format(total),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: isChange ? Colors.red.shade700 : AppTheme.black,
                      ),
                    ),
                    if (isChange)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Was ${formatCurrency.format(total * 0.9)}',
                          style: const TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isChange && discount > 0) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'You saved ${formatCurrency.format(discount)} on this order',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isProcessing = _currentState == CheckoutState.processing;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      decoration: const BoxDecoration(color: AppTheme.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isProcessing
                  ? null
                  : () {
                      final addressProvider = Provider.of<AddressProvider>(
                        context,
                        listen: false,
                      );
                      final cartProvider = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );
                      final address = addressProvider.defaultAddress;
                      if (address == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add a shipping address'),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            addressId: address.id ?? '',
                            shippingFee: cartProvider.shippingFee,
                            discount: cartProvider.discount,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isProcessing
                    ? AppTheme.greyBackground
                    : AppTheme.black,
                foregroundColor: AppTheme.white,
                disabledBackgroundColor: AppTheme.greyBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isProcessing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppTheme.greyText,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Placing your order...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Expanded(child: SizedBox()),
                        Icon(Icons.lock_outline, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(PhosphorIcons.arrowRight, size: 18),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: AppTheme.greyText),
              const SizedBox(width: 6),
              const Text(
                'Secure Checkout',
                style: TextStyle(color: AppTheme.greyText, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isProcessing
                ? 'Please don\'t close this screen'
                : 'Your details are safe with us',
            style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
