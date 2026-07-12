import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets/primary_button.dart';
import 'apply_coupon_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart (3)', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined, size: 16, color: AppTheme.black.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text('100% Secure', style: TextStyle(fontSize: 12, color: AppTheme.black.withOpacity(0.7))),
              ],
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Review text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Review your items and proceed to checkout', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 16),
            // Free shipping progress
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(color: AppTheme.black, fontSize: 12),
                            children: [
                              TextSpan(text: 'You\'re '),
                              TextSpan(text: '₹5,000 ', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: 'away from FREE shipping!'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: 0.7,
                          backgroundColor: AppTheme.greyBorder,
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('₹0', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
                            Text('₹5,000', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildCartItem(
              title: 'boAt Airdopes 141 Pro\nTWS Earbuds',
              color: 'Active Black',
              price: '₹1,299',
              totalPrice: '₹12,990 (10 units)',
              qty: '10',
              moq: '10 units',
              stockStatus: 'In Stock',
              isError: false,
            ),
            _buildCartItem(
              title: 'Apple MacBook Air M2\n(16GB, 256GB)',
              color: 'Midnight',
              price: '₹1,09,900',
              totalPrice: '₹1,09,900 (1 unit)',
              qty: '1',
              moq: '2 units',
              stockStatus: 'Only 6 left',
              isWarning: true,
              errorMessage: 'Minimum order is 2 units. Add 1 more unit to proceed.',
            ),
            _buildCartItem(
              title: 'Mi 20000mAh Power Bank 3i',
              color: 'Black',
              price: '₹1,299',
              totalPrice: '₹6,495 (5 units)',
              qty: '5',
              moq: '5 units',
              stockStatus: 'Only 15 left',
              isWarning: true,
              warningMessage: 'Stock updated: Only 15 left (was 25 when added to cart)',
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ApplyCouponScreen()));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.greyBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, color: AppTheme.black),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Have a coupon code?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Apply code to get instant discount', style: TextStyle(color: AppTheme.greyText, fontSize: 10)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: AppTheme.black, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.greyBackground.withOpacity(0.5),
              child: Column(
                children: [
                  _buildPriceRow('Subtotal (16 items)', '₹1,29,385'),
                  const SizedBox(height: 8),
                  _buildPriceRow('Discount', '- ₹5,000', color: Colors.green),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Shipping Estimate', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Icon(Icons.info_outline, size: 12, color: AppTheme.greyText),
                        ],
                      ),
                      const Text('₹299', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: AppTheme.greyBorder, height: 1),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 2),
                          Text('All prices are exclusive of GST', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
                        ],
                      ),
                      Text('₹1,24,684', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Proceed to Checkout',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
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
  }

  Widget _buildCartItem({
    required String title,
    required String color,
    required String price,
    required String totalPrice,
    required String qty,
    required String moq,
    required String stockStatus,
    bool isError = false,
    bool isWarning = false,
    String? errorMessage,
    String? warningMessage,
  }) {
    return Container(
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
                  child: Image.asset('assets/images/phone.png', fit: BoxFit.cover),
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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const Icon(Icons.close, size: 16, color: AppTheme.greyText),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Color: $color', style: const TextStyle(color: AppTheme.greyText, fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isWarning ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stockStatus,
                        style: TextStyle(
                          color: isWarning ? Colors.orange : Colors.green,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.greyBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('MOQ: $moq', style: const TextStyle(fontSize: 8)),
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
                              const Icon(Icons.remove, size: 12),
                              Text(qty, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const Icon(Icons.add, size: 12),
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
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              Text(totalPrice, style: const TextStyle(color: AppTheme.greyText, fontSize: 10)),
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
                  const Icon(Icons.error_outline, color: AppTheme.error, size: 14),
                  const SizedBox(width: 8),
                  Expanded(child: Text(errorMessage, style: const TextStyle(color: AppTheme.error, fontSize: 10))),
                ],
              ),
            ),
          ],
          if (warningMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 14),
                  const SizedBox(width: 8),
                  Expanded(child: Text(warningMessage, style: const TextStyle(color: Colors.orange, fontSize: 10))),
                  const Text('View Details', style: TextStyle(color: Colors.orange, fontSize: 10, decoration: TextDecoration.underline)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color color = AppTheme.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
      ],
    );
  }
}
