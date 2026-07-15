import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';

class CategoryLaptopsScreen extends StatelessWidget {
  const CategoryLaptopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Laptops & Tablets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('842 products', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              margin: const EdgeInsets.all(16),
              height: 140,
              decoration: BoxDecoration(
                color: AppTheme.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Power your\nbusiness', style: TextStyle(color: AppTheme.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('High performance laptops\nfor every need.', style: TextStyle(color: AppTheme.white, fontSize: 10)),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(Icons.laptop_mac, size: 120, color: AppTheme.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Shop by Sub-category', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildSubCategoryChip('All', Icons.grid_view, true),
                  _buildSubCategoryChip('Laptops', Icons.laptop, false),
                  _buildSubCategoryChip('2 in 1 Laptops', Icons.laptop_chromebook, false),
                  _buildSubCategoryChip('Tablets', Icons.tablet_mac, false),
                  _buildSubCategoryChip('Accessories', Icons.headphones, false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 16, color: AppTheme.black),
                    label: const Text('Filter', style: TextStyle(color: AppTheme.black)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.greyBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.black),
                    label: const Text('Sort by: Best Selling', style: TextStyle(color: AppTheme.black)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.greyBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ProductCard(
                  imageUrl: 'assets/images/laptop.png',
                  title: index == 0 ? 'Dell Latitude 5440\n(13th Gen, i5, 16GB, 512GB)' : 'Laptop Model',
                  price: 'â‚¹78,990',
                  moq: 'MOQ: 5 units',
                  stockStatus: index == 3 ? 'Low Stock (5 left)' : 'In Stock',
                  isLowStock: index == 3,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailsScreen()));
                  },
                  onAdd: () {},
                );
              },
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.greyBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 48, color: AppTheme.greyText),
                  const SizedBox(height: 16),
                  const Text('No products in this category', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('We\'re working on adding products here.\nPlease check back later.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.black,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Browse other categories'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryChip(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.black : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppTheme.black : AppTheme.greyBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? AppTheme.white : AppTheme.black),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: isSelected ? AppTheme.white : AppTheme.black, fontSize: 12)),
        ],
      ),
    );
  }
}
