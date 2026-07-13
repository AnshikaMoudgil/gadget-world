import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/product_card.dart';
import 'package:gadget_store/features/products/screens/product_details_screen.dart';

class CategoryMobilesScreen extends StatelessWidget {
  const CategoryMobilesScreen({super.key});

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
            Text('Mobile Phones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('1,256 products', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.greyBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.grid_view, size: 20, color: AppTheme.white),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.list, size: 20, color: AppTheme.black),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, size: 16, color: AppTheme.black),
                    label: const Text('Filter', style: TextStyle(color: AppTheme.black)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.greyBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.swap_vert, size: 16, color: AppTheme.black),
                    label: const Text('Sort', style: TextStyle(color: AppTheme.black)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.greyBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDropdownChip('Category'),
                  _buildDropdownChip('Brand'),
                  _buildDropdownChip('Price Range'),
                  _buildDropdownChip('Availability'),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Clear All', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Sort by: Best Selling', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
              itemCount: 6,
              itemBuilder: (context, index) {
                return ProductCard(
                  imageUrl: 'assets/images/phone.png',
                  title: 'Apple iPhone 15 (128GB)',
                  price: 'â‚¹69,900',
                  moq: 'MOQ: 5 units',
                  stockStatus: index == 2 || index == 4 ? 'Low Stock' : 'In Stock',
                  isLowStock: index == 2 || index == 4,
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, color: AppTheme.black),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('No products match your filters', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Try adjusting or clearing your filters to see more results.', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh, size: 16, color: AppTheme.white),
                          label: const Text('Reset Filters', style: TextStyle(color: AppTheme.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.greyBorder),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.black),
        ],
      ),
    );
  }
}
