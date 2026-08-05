import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/theme.dart';
import '../../cart/providers/cart_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApplyCouponScreen extends StatefulWidget {
  const ApplyCouponScreen({super.key});

  @override
  State<ApplyCouponScreen> createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  final TextEditingController _couponController = TextEditingController();
  List<Map<String, dynamic>> _availableCoupons = [];
  bool _isLoadingCoupons = true;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      if (cartProvider.appliedCouponCode != null) {
        _couponController.text = cartProvider.appliedCouponCode!;
      }
    });
  }

  Future<void> _fetchCoupons() async {
    try {
      final res = await Supabase.instance.client
          .from('coupons')
          .select()
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _availableCoupons = List<Map<String, dynamic>>.from(res as List);
          _isLoadingCoupons = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCoupons = false);
      }
    }
  }

  void _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.applyCoupon(code);

    // UI will update because of Consumer, but we can also handle success/error messages here if we wanted.
  }

  void _removeCoupon() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeCoupon();
    _couponController.text = '';
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final isSuccess = cartProvider.appliedCouponCode != null;
          final hasError =
              cartProvider.error != null &&
              cartProvider.appliedCouponCode == null;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (isSuccess) _buildSuccessBanner(cartProvider),
                    if (isSuccess) const SizedBox(height: 16),
                    _buildInputArea(cartProvider),
                    if (hasError) _buildErrorBanner(cartProvider.error!),
                    const SizedBox(height: 32),
                    const Text(
                      'Available Offers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Best offers for you, automatically applied at checkout',
                      style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingCoupons)
                      const Center(child: CircularProgressIndicator())
                    else if (_availableCoupons.isEmpty)
                      const Center(
                        child: Text(
                          'No available offers right now.',
                          style: TextStyle(color: AppTheme.greyText),
                        ),
                      )
                    else
                      ..._availableCoupons.map((coupon) {
                        final code = coupon['code'] as String;
                        final minOrder = coupon['min_order_value'] != null
                            ? 'Min. order ₹${coupon['min_order_value']}'
                            : 'No min. order';
                        String discountStr = '';
                        String maxDiscountStr = '';
                        IconData iconData = Icons.local_offer_outlined;

                        if (coupon['discount_type'] == 'percentage') {
                          discountStr = '${coupon['discount_value']}% OFF';
                          maxDiscountStr = coupon['max_discount_amount'] != null
                              ? 'Max. discount ₹${coupon['max_discount_amount']}'
                              : 'Percentage off';
                          iconData = Icons.workspace_premium_outlined;
                        } else if (coupon['discount_type'] == 'fixed_amount') {
                          discountStr = '₹${coupon['discount_value']} OFF';
                          maxDiscountStr = 'Flat amount off';
                          iconData = Icons.lock_outline;
                        } else if (coupon['discount_type'] == 'free_shipping') {
                          discountStr = 'Free Shipping';
                          maxDiscountStr = 'Saves shipping fee';
                          iconData = Icons.local_shipping_outlined;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildOfferCard(
                            code: code,
                            discount: discountStr,
                            minOrder: minOrder,
                            maxDiscount: maxDiscountStr,
                            icon: iconData,
                            isApplied: isSuccess &&
                                cartProvider.appliedCouponCode == code,
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 32),
                    _buildFooterInfo(),
                    const SizedBox(
                      height: 100,
                    ), // spacing for bottom bar if needed
                  ],
                ),
              ),
              if (isSuccess)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: _buildTotalSavingsBox(cartProvider),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Apply Coupon',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Enter a coupon code to get discount',
          style: TextStyle(fontSize: 12, color: AppTheme.greyText),
        ),
      ],
    );
  }

  Widget _buildInputArea(CartProvider cartProvider) {
    final isDisabled = cartProvider.appliedCouponCode != null;
    final hasError =
        cartProvider.error != null && cartProvider.appliedCouponCode == null;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDisabled ? AppTheme.greyBackground : AppTheme.white,
              border: Border.all(color: AppTheme.greyBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.local_activity_outlined,
                  color: isDisabled ? AppTheme.greyText : AppTheme.black,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    enabled: !isDisabled,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      hintStyle: TextStyle(
                        color: AppTheme.greyText,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(
                      Icons.cancel_outlined,
                      color: AppTheme.black,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: isDisabled ? null : _applyCoupon,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey.shade400 : AppTheme.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: cartProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Apply',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String errorMsg) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMsg,
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_activity_outlined,
              color: Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cartProvider.appliedCouponCode ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        cartProvider.discountType == 'percentage'
                            ? 'PERCENTAGE OFF'
                            : 'FLAT OFF',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'You saved ₹${cartProvider.discount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.black),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _removeCoupon,
            child: const Icon(Icons.close, color: AppTheme.black, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String code,
    required String discount,
    required String minOrder,
    required String maxDiscount,
    required IconData icon,
    bool isBestOffer = false,
    bool isApplied = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(
          color: isApplied ? Colors.green.shade300 : AppTheme.greyBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.greyBorder,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(icon, size: 20, color: AppTheme.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isBestOffer)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'BEST OFFER',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      discount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  minOrder,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  maxDiscount,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: AppTheme.greyText, size: 16),
          SizedBox(width: 8),
          Text(
            'Only one coupon can be applied per order',
            style: TextStyle(color: AppTheme.greyText, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSavingsBox(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Colors.green,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Savings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You saved ₹${cartProvider.discount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.black),
                ),
              ],
            ),
          ),
          Text(
            cartProvider.appliedCouponCode ?? '',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
