import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/checkout/screens/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import 'package:gadget_store/features/profile/providers/address_provider.dart';
import 'package:intl/intl.dart';

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
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
              bottom: 120,
            ), // Leave space for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                if (_currentState == CheckoutState.priceChange)
                  _buildPriceChangeWarning(),
                _buildSectionTitle('1. Shipping Address', true),
                _buildShippingAddress(),
                _buildSectionTitle('2. Order Summary', false),
                _buildOrderSummary(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Divider(color: AppTheme.greyBorder, height: 32),
                ),
                _buildCostSummary(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Divider(color: AppTheme.greyBorder, height: 32),
                ),
                _buildTotalAmount(),
                const SizedBox(height: 58),
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please review your order details before placing',
                  style: TextStyle(fontSize: 12, color: AppTheme.greyText),
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
                  Icons.assignment_outlined,
                  size: 48,
                  color: AppTheme.greyText,
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppTheme.white,
                      size: 16,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Price Change Detected',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Some prices have changed since you last reviewed your cart.',
                  style: TextStyle(fontSize: 10, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
          Text(
            'View details',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool showChangeBtn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppTheme.black,
            ),
          ),
          if (showChangeBtn)
            const Text(
              'Change',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                decoration: TextDecoration.underline,
                color: AppTheme.black,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: AppTheme.greyBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'No address selected. Please add an address to proceed.',
          style: TextStyle(color: AppTheme.greyText),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: AppTheme.black,
            size: 20,
          ),
          const SizedBox(width: 12),
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
                        fontSize: 14,
                        color: AppTheme.black,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Default',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 8,
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
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  address.phoneNumber,
                  style: const TextStyle(
                    color: AppTheme.black,
                    fontSize: 12,
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

              return _buildOrderItem(
                title: product?['name'] as String? ?? 'Unknown Product',
                color: variantName,
                qty: item.quantity,
                price: formatCurrency.format(price),
                hasPriceChange: _currentState == CheckoutState.priceChange,
                newPrice: formatCurrency.format(oldPrice),
                priceDiff: '↑ ${formatCurrency.format(oldPrice - price)}',
              );
            },
          ),
          if (i < cart.items.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Divider(color: AppTheme.greyBorder, height: 1),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.greyBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.headphones,
              color: AppTheme.greyText,
            ), // placeholder icon
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  color,
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $qty',
                  style: const TextStyle(color: AppTheme.black, fontSize: 10),
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
                  fontSize: 14,
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
                      fontSize: 10,
                    ),
                  ),
                ),
              if (hasPriceChange)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        priceDiff!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 10,
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
          const SizedBox(height: 8),
          _buildCostRow(
            'Coupon Discount',
            '-${formatCurrency.format(discount)}',
            null,
            color: Colors.green,
          ),
          const SizedBox(height: 8),
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
                fontSize: 12,
                color: color == Colors.green ? Colors.green : AppTheme.greyText,
              ),
            ),
            if (showInfoIcon) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.info_outline,
                size: 12,
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
                fontSize: 12,
                color: color,
              ),
            ),
            if (oldVal != null) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: 65,
                child: Text(
                  oldVal,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppTheme.greyText,
                    fontSize: 10,
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
            padding: EdgeInsets.all(isChange ? 12 : 0),
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
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '(Inclusive of all taxes)',
                      style: TextStyle(fontSize: 10, color: AppTheme.greyText),
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
                        fontSize: 20,
                        color: isChange ? Colors.red.shade700 : AppTheme.black,
                      ),
                    ),
                    if (isChange)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Was ${formatCurrency.format(total * 0.9)}',
                          style: const TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!isChange && discount > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'You saved ${formatCurrency.format(discount)} on this order',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 12,
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
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.greyBorder, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
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
                  borderRadius: BorderRadius.circular(8),
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
                        SizedBox(width: 12),
                        Text(
                          'Placing your order...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_outline, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 12, color: AppTheme.greyText),
              const SizedBox(width: 4),
              const Text(
                'Secure Checkout',
                style: TextStyle(color: AppTheme.greyText, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isProcessing
                ? 'Please don\'t close this screen'
                : 'Your details are safe with us',
            style: const TextStyle(color: AppTheme.greyText, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
