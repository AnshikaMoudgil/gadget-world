import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/widgets/product_card.dart';
import 'product_details_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.greyBorder),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'wireless earbuds',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: AppTheme.greyText),
              suffixIcon: Icon(Icons.close, color: AppTheme.greyText),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
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
                    label: const Text('Sort by: Relevance', style: TextStyle(color: AppTheme.black)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.greyBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Clear All', style: TextStyle(fontSize: 12, decoration: TextDecoration.underline, color: AppTheme.greyText.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildRecentSearchChip('wireless earbuds'),
                  _buildRecentSearchChip('power banks'),
                  _buildRecentSearchChip('usb c cable'),
                  _buildRecentSearchChip('smart watch'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppTheme.black, fontSize: 14),
                      children: [
                        TextSpan(text: 'Results for '),
                        TextSpan(text: '"wireless earbuds"', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' (124 results)', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.grid_view, size: 16, color: AppTheme.white),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.list, size: 20, color: AppTheme.black),
                    ],
                  )
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
                childAspectRatio: 0.58,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return ProductCard(
                  imageUrl: index.isEven ? 'assets/images/laptop.png' : 'assets/images/phone.png',
                  title: 'boAt Airdopes 141 Pro TWS Earbuds',
                  price: '₹1,299',
                  moq: 'MOQ: 5 units',
                  stockStatus: index == 2 ? 'Low Stock (7 left)' : 'In Stock',
                  isLowStock: index == 2,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, size: 32, color: AppTheme.black),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('No results found for "wireless earbudss"', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('We couldn\'t find any products matching your search. Try checking the spelling or use different keywords.', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                        const SizedBox(height: 16),
                        const Text('Suggestions:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSuggestionChip('wireless earbuds'),
                            _buildSuggestionChip('earbuds'),
                            _buildSuggestionChip('bluetooth earbuds'),
                            _buildSuggestionChip('earphones'),
                          ],
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

  Widget _buildRecentSearchChip(String label) {
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
          const Icon(Icons.history, size: 14, color: AppTheme.greyText),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.close, size: 14, color: AppTheme.greyText),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyBorder),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}
