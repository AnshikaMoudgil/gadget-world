import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/core/theme.dart';
import '../../cart/providers/cart_provider.dart';
import '../services/coupon_api_service.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ApplyCouponScreen extends StatefulWidget {
  const ApplyCouponScreen({super.key});

  @override
  State<ApplyCouponScreen> createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  final TextEditingController _couponController = TextEditingController();
  final CouponApiService _apiService = CouponApiService();

  List<Map<String, dynamic>> _availableCoupons = [];
  bool _isLoadingCoupons = true;
  String? _errorMsg;

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
      final res = await _apiService.getAvailableCoupons();
      if (mounted) {
        setState(() {
          _availableCoupons = res;
          _isLoadingCoupons = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCoupons = false);
      }
    }
  }

  void _applyCoupon([String? codeToApply]) async {
    final code = codeToApply ?? _couponController.text.trim();
    if (code.isEmpty) return;

    if (codeToApply != null && _couponController.text != codeToApply) {
      _couponController.text = codeToApply;
    }

    setState(() {
      _errorMsg = null;
    });

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.applyCoupon(code);

    if (cartProvider.error != null) {
      setState(() {
        _errorMsg = cartProvider.error;
      });
    }
  }

  void _removeCoupon() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeCoupon();
    _couponController.text = '';
    setState(() {
      _errorMsg = null;
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Widget _buildTopGraphic() {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 20,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.greyBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.greyText,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -10,
            top: 30,
            child: Transform.rotate(
              angle: 0.1,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.black,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            right: 40,
            top: 10,
            child: Icon(Icons.star, size: 10, color: AppTheme.black),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(CartProvider provider) {
    final discountType = provider.discountType;
    final discountStr = discountType == 'percentage'
        ? 'Discount Applied' // Assuming we don't store percentage amount cleanly in provider yet
        : discountType == 'free_shipping'
        ? 'Free Shipping'
        : 'Discount Applied';

    final formatter = NumberFormat.simpleCurrency(
      name: 'INR',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.05),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.local_activity_outlined,
              color: Colors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      provider.appliedCouponCode ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      discountType == 'free_shipping' ? 'FREE' : discountStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'You saved ${formatter.format(provider.discount)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _removeCoupon,
            child: const Icon(Icons.close, size: 20, color: AppTheme.black),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.simpleCurrency(
      name: 'INR',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.white,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final isSuccess = cartProvider.appliedCouponCode != null;
          final isError = _errorMsg != null;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
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
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.greyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildTopGraphic(),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (isSuccess) _buildSuccessBanner(cartProvider),

                    // Input Field
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? AppTheme.greyBackground
                            : AppTheme.white,
                        border: Border.all(color: AppTheme.greyBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.local_activity_outlined,
                              color: AppTheme.greyText,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _couponController,
                              enabled: !isSuccess,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                hintText: 'Enter coupon code',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.greyText,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (isSuccess)
                            const Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Icon(
                                Icons.cancel,
                                color: AppTheme.greyText,
                                size: 18,
                              ),
                            ),
                          GestureDetector(
                            onTap: (isSuccess || cartProvider.isLoading)
                                ? null
                                : () => _applyCoupon(),
                            child: Container(
                              height: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: isSuccess
                                    ? AppTheme.greyBorder
                                    : AppTheme.black,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: cartProvider.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Apply',
                                      style: TextStyle(
                                        color: isSuccess
                                            ? AppTheme.greyText
                                            : AppTheme.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (isError) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

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
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_availableCoupons.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(
                          child: Text(
                            'No available offers right now.',
                            style: TextStyle(color: AppTheme.greyText),
                          ),
                        ),
                      )
                    else
                      ..._availableCoupons.map((coupon) {
                        final code = coupon['code'] as String;
                        final minOrder = coupon['min_order_value'] != null
                            ? 'Min. order ${formatter.format(num.tryParse(coupon['min_order_value'].toString()) ?? 0)}'
                            : 'No minimum order';
                        String discountStr = '';
                        String maxDiscountStr = '';
                        IconData iconData = Icons.local_offer_outlined;

                        if (coupon['discount_type'] == 'percentage') {
                          discountStr = '${coupon['discount_value']}% OFF';
                          maxDiscountStr = coupon['max_discount_amount'] != null
                              ? 'Max. discount ${formatter.format(num.tryParse(coupon['max_discount_amount'].toString()) ?? 0)}'
                              : 'Percentage off';
                          iconData = Icons.workspace_premium_outlined;
                        } else if (coupon['discount_type'] == 'fixed_amount') {
                          discountStr =
                              '${formatter.format(num.tryParse(coupon['discount_value'].toString()) ?? 0)} OFF';
                          maxDiscountStr = 'Flat amount off';
                          iconData = Icons.lock_outline;
                        } else if (coupon['discount_type'] == 'free_shipping') {
                          discountStr = 'Free Shipping';
                          maxDiscountStr = 'Saves shipping fee';
                          iconData = Icons.local_shipping_outlined;
                        }

                        final validUntilStr = coupon['valid_until'];
                        String validity = 'No expiry';
                        if (validUntilStr != null) {
                          try {
                            final dt = DateTime.parse(validUntilStr);
                            validity =
                                'Valid till ${DateFormat('dd MMM yyyy').format(dt)}';
                          } catch (_) {}
                        }

                        final isCouponApplied =
                            cartProvider.appliedCouponCode == code;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            border: Border.all(
                              color: isCouponApplied
                                  ? Colors.green.withValues(alpha: 0.3)
                                  : AppTheme.greyBorder,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: isSuccess ? null : () => _applyCoupon(code),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.greyBorder,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      iconData,
                                      size: 20,
                                      color: AppTheme.black,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (coupon['discount_type'] ==
                                                'percentage' &&
                                            coupon['discount_value'] >= 20)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              bottom: 6,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.black,
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              code,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              discountStr,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          minOrder,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.greyText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          maxDiscountStr,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.greyText,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.timer_outlined,
                                              size: 12,
                                              color: AppTheme.greyText,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              validity,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.greyText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (isCouponApplied) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: const [
                                              Icon(
                                                Icons.check_circle,
                                                size: 12,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Applied',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.greyBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppTheme.greyText,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Only one coupon can be applied per order',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),

              if (isSuccess)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_offer,
                            color: Colors.green,
                            size: 20,
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
                                    fontSize: 13,
                                    color: AppTheme.black,
                                  ),
                                ),
                                Text(
                                  'You saved ${formatter.format(cartProvider.discount)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            cartProvider.discountType == 'percentage'
                                ? 'Applied'
                                : '${formatter.format(cartProvider.discount)} OFF',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
