import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Container(
              height: 300,
              color: AppTheme.greyBackground,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.asset('assets/images/phone.png', fit: BoxFit.contain, height: 250),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) => 
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0 ? AppTheme.black : AppTheme.greyBorder,
                          ),
                        )
                      ),
                    ),
                  )
                ],
              ),
            ),
            // Thumbnails
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(4, (index) => 
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: index == 0 ? AppTheme.black : AppTheme.greyBorder),
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.greyBackground,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset('assets/images/phone.png', fit: BoxFit.cover),
                    ),
                  )
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('boAt', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    'boAt Airdopes 141 Pro\nTWS Earbuds',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('4.5', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.star, size: 16, color: AppTheme.black),
                      const SizedBox(width: 8),
                      Text('(1,256 reviews)', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('â‚¹1,299', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text('â‚¹2,499', style: TextStyle(decoration: TextDecoration.lineThrough, color: AppTheme.greyText, fontSize: 14)),
                      const SizedBox(width: 8),
                      const Text('48% OFF', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('In Stock', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      const Text('Only 40 left!', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Text('Minimum order: 10 units', style: TextStyle(color: Colors.blue, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppTheme.black),
                      children: [
                        TextSpan(text: 'Bulk pricing ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '(per unit)', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulkPricingTable(),
                  const SizedBox(height: 24),
                  const Text('Select Variant', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Color', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildVariantChip('Active Black', Colors.black, true),
                      _buildVariantChip('Cool Blue', Colors.blue.shade900, false),
                      _buildVariantChip('Pearl White', AppTheme.white, false),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Key Features', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Text('View all', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const Icon(Icons.arrow_forward_ios, size: 12),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureIcon(Icons.waves, '42dB Active\nNoise Cancellation'),
                      _buildFeatureIcon(Icons.battery_charging_full, 'Up to 42H\nBattery Life'),
                      _buildFeatureIcon(Icons.water_drop_outlined, 'IPX4\nWater Resistant'),
                      _buildFeatureIcon(Icons.bluetooth, 'Bluetooth 5.3\nSeamless Connect'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.greyBorder),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Specifications', style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Icon(Icons.keyboard_arrow_down, color: AppTheme.black),
                  ),
                  _buildSpecRow('Driver Size', '10mm'),
                  _buildSpecRow('Bluetooth Version', '5.3'),
                  _buildSpecRow('Playback Time', 'Up to 42 Hours (with case)'),
                  _buildSpecRow('Charging Time', 'Up to 1.5 Hours'),
                  _buildSpecRow('Water Resistance', 'IPX4'),
                  _buildSpecRow('Mic', 'ENxâ„¢ Technology'),
                  const SizedBox(height: 24),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppTheme.black),
                      children: [
                        TextSpan(text: 'Quantity ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '(Minimum 10 units)', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.greyBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: () {}),
                        const Text('10', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.add, size: 16), onPressed: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border(top: BorderSide(color: AppTheme.greyBorder)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border, color: AppTheme.black),
                  label: const Text('Add to Wishlist', style: TextStyle(color: AppTheme.black)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.greyBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.white),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulkPricingTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.greyBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.greyBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quantity (Units)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text('Price (â‚¹/Unit)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildPricingRow('10 - 49', 'â‚¹1,299'),
          const Divider(height: 1, color: AppTheme.greyBorder),
          _buildPricingRow('50 - 199', 'â‚¹1,199'),
          const Divider(height: 1, color: AppTheme.greyBorder),
          _buildPricingRow('200 - 499', 'â‚¹1,099'),
          const Divider(height: 1, color: AppTheme.greyBorder),
          _buildPricingRow('500+', 'â‚¹999'),
        ],
      ),
    );
  }

  Widget _buildPricingRow(String qty, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(qty, style: const TextStyle(fontSize: 12)),
          Text(price, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildVariantChip(String label, Color color, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: isSelected ? AppTheme.black : AppTheme.greyBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.greyBorder),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.black),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 8)),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(color: AppTheme.greyText, fontSize: 12))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }
}
