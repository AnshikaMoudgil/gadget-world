import 'package:flutter/material.dart';
import '../core/theme.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Toggle this to true to see the empty state
  bool _isEmptyState = false;

  final List<Map<String, dynamic>> _wishlistItems = [
    {
      'name': 'boAt Rockerz 450',
      'category': 'Over Ear Headphones',
      'price': '₹1,999',
      'image': Icons.headphones, // Placeholder icon
    },
    {
      'name': 'Noise ColorFit Pulse 3',
      'category': 'Smartwatch',
      'price': '₹5,998',
      'image': Icons.watch, // Placeholder icon
    },
    {
      'name': 'Ambrane 10000mAh Power Bank',
      'category': 'Power Bank',
      'price': '₹1,199',
      'image': Icons.battery_charging_full, // Placeholder icon
    },
    {
      'name': 'boAt Airdopes 141',
      'category': 'Wireless Earbuds',
      'price': '₹1,499',
      'image': Icons.earbuds, // Placeholder icon
    },
    {
      'name': 'OnePlus Nord Buds 2',
      'category': 'Wireless Earbuds',
      'price': '₹2,999',
      'image': Icons.earbuds, // Placeholder icon
    },
    {
      'name': 'Samsung Galaxy Fit3',
      'category': 'Smartwatch',
      'price': '₹4,999',
      'image': Icons.watch, // Placeholder icon
    },
  ];

  void _showRemoveBottomSheet(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.greyBorder, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Remove Item?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.black)),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to remove this item\nfrom your wishlist?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.black,
                        side: const BorderSide(color: AppTheme.greyBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _wishlistItems.removeAt(index);
                          if (_wishlistItems.isEmpty) {
                            _isEmptyState = true;
                          }
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.black,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Remove', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            if (!_isEmptyState)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_wishlistItems.length} Items', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                    const Text('Edit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                  ],
                ),
              ),
            Expanded(
              child: _isEmptyState ? _buildEmptyState() : _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Wishlist', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Saved items you love', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.black), onPressed: () {}),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: AppTheme.black, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: const Text('2', style: TextStyle(color: AppTheme.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65, // Adjust for product card height
      ),
      itemCount: _wishlistItems.length,
      itemBuilder: (context, index) {
        final item = _wishlistItems[index];
        return _buildProductCard(item, index);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Area
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.greyBackground.withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(item['image'] as IconData, size: 48, color: AppTheme.black), // Placeholder for actual image
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showRemoveBottomSheet(index),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppTheme.black, shape: BoxShape.circle),
                        child: const Icon(Icons.favorite, color: AppTheme.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Details Area
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['category'],
                        style: const TextStyle(fontSize: 10, color: AppTheme.greyText),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['price'],
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.black,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.shopping_cart_outlined, size: 14),
                          SizedBox(width: 4),
                          Text('Add to Cart', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Graphic Placeholder
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: AppTheme.greyBackground.withOpacity(0.5), shape: BoxShape.circle),
                  ),
                  const Icon(Icons.favorite_border, size: 64, color: AppTheme.greyText),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Your wishlist is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.black)),
            const SizedBox(height: 12),
            const Text(
              'Save items you love and find them\nhere anytime.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.greyText, height: 1.4),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Categories or Home
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.black,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Browse Catalog', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
