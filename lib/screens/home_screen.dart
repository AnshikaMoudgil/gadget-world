import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets/logo_widget.dart';
import 'search_results_screen.dart';
import 'category_laptops_screen.dart';
import 'category_mobiles_screen.dart';
import 'product_details_screen.dart';
import 'best_sellers_screen.dart';
import 'new_arrivals_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              const LogoWidget(size: 32),
              const SizedBox(width: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 18, color: AppTheme.black),
                  children: [
                    TextSpan(text: 'Gadget ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'World', style: TextStyle(fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchResultsScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.greyBorder),
                  ),
                  child: const TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Search for products, brands and more...',
                      hintStyle: TextStyle(color: AppTheme.greyText, fontSize: 14),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: AppTheme.greyText),
                      suffixIcon: Icon(Icons.center_focus_weak, color: AppTheme.greyText),
                    ),
                  ),
                ),
              ),
            ),
            _buildSectionHeader('Shop by Category'),
            _buildCategories(),
            const SizedBox(height: 24),
            _buildSectionHeader('Best Sellers', onViewAll: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const BestSellersScreen()));
            }),
            _buildHorizontalProductList(),
            const SizedBox(height: 24),
            _buildSectionHeader('New Arrivals', onViewAll: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NewArrivalsScreen()));
            }),
            _buildHorizontalProductList(),
            const SizedBox(height: 24),
            _buildSectionHeader('Featured Products'),
            _buildHorizontalProductList(),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.greyBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.black),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No products available', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('We\'re working on adding amazing products.\nPlease check back later.', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  const Text('View All', style: TextStyle(fontSize: 12, color: AppTheme.black, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            )
          else
            Row(
              children: [
                const Text('View All', style: TextStyle(fontSize: 12, color: AppTheme.black, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 12),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.phone_android, 'name': 'Mobile\nPhones'},
      {'icon': Icons.laptop, 'name': 'Laptops &\nTablets'},
      {'icon': Icons.headphones, 'name': 'Audio'},
      {'icon': Icons.watch, 'name': 'Wearables'},
      {'icon': Icons.cable, 'name': 'Chargers &\nCables'},
      {'icon': Icons.grid_view, 'name': 'More\nCategories'},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryMobilesScreen()));
              } else if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryLaptopsScreen()));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.greyBorder),
                    ),
                    child: Icon(categories[index]['icon'] as IconData, size: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categories[index]['name'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalProductList() {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductDetailsScreen()));
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.greyBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.greyBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset('assets/images/laptop.png', fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Bestseller', style: TextStyle(color: AppTheme.white, fontSize: 8)),
                        ),
                      ),
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: Icon(Icons.favorite_border, size: 20, color: AppTheme.greyText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Product Name Example Very Long',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '₹999',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: AppTheme.white, size: 16),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
