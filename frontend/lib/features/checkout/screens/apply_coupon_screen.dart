import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';

enum CouponState { initial, error, success }

class ApplyCouponScreen extends StatefulWidget {
  const ApplyCouponScreen({super.key});

  @override
  State<ApplyCouponScreen> createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  CouponState _currentState = CouponState.initial;
  final TextEditingController _couponController = TextEditingController();

  void _cycleState() {
    setState(() {
      if (_currentState == CouponState.initial) {
        _currentState = CouponState.error;
        _couponController.text = 'SAVE50';
      } else if (_currentState == CouponState.error) {
        _currentState = CouponState.success;
        _couponController.text = ''; // usually disabled or empty
      } else {
        _currentState = CouponState.initial;
        _couponController.text = '';
      }
    });
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                if (_currentState == CouponState.success) _buildSuccessBanner(),
                if (_currentState == CouponState.success)
                  const SizedBox(height: 16),
                _buildInputArea(),
                if (_currentState == CouponState.error) _buildErrorBanner(),
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
                _buildOfferCard(
                  code: 'SAVE20',
                  discount: '20% OFF',
                  minOrder: 'Min. order â‚¹1,999',
                  maxDiscount: 'Max. discount â‚¹1,000',
                  icon: Icons.workspace_premium_outlined,
                  isBestOffer: true,
                  isApplied: _currentState == CouponState.success,
                ),
                const SizedBox(height: 16),
                _buildOfferCard(
                  code: 'NEW10',
                  discount: '10% OFF',
                  minOrder: 'Min. order â‚¹999',
                  maxDiscount: 'Max. discount â‚¹500',
                  icon: Icons.lock_outline,
                ),
                const SizedBox(height: 16),
                _buildOfferCard(
                  code: 'WELCOME5',
                  discount: '5% OFF',
                  minOrder: 'No minimum order',
                  maxDiscount: 'Max. discount â‚¹200',
                  icon: Icons.local_offer_outlined,
                ),
                const SizedBox(height: 32),
                _buildFooterInfo(),
                const SizedBox(height: 100), // spacing for bottom bar if needed
              ],
            ),
          ),
          if (_currentState == CouponState.success)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: _buildTotalSavingsBox(),
            ),
        ],
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

  Widget _buildInputArea() {
    final isDisabled = _currentState == CouponState.success;
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
                if (_currentState == CouponState.error)
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
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade400 : AppTheme.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'Apply',
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
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
          Text(
            'Invalid or expired coupon code.',
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
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
                    const Text(
                      'SAVE20',
                      style: TextStyle(
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
                      child: const Text(
                        '20% OFF',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'You saved â‚¹600',
                  style: TextStyle(fontSize: 12, color: AppTheme.black),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _currentState = CouponState.initial;
                _couponController.text = '';
              });
            },
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
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppTheme.greyText,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Valid till 31 Jul 2026',
                      style: TextStyle(fontSize: 10, color: AppTheme.greyText),
                    ),
                  ],
                ),
                if (isApplied)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Applied',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildTotalSavingsBox() {
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
              children: const [
                Text(
                  'Total Savings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You saved â‚¹600',
                  style: TextStyle(fontSize: 12, color: AppTheme.black),
                ),
              ],
            ),
          ),
          const Text(
            '20% OFF',
            style: TextStyle(
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
