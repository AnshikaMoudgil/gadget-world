import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/core/widgets/product_card.dart';
import '../models/product_model.dart';
import '../providers/catalog_provider.dart';
import 'product_details_screen.dart';
import 'package:gadget_world/features/cart/providers/cart_provider.dart';
import '../../checkout/screens/cart_screen.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CatalogProvider>(context, listen: false);
      provider.loadRecentSearches();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    final q = query.trim();
    setState(() {
      _query = q;
      if (_searchController.text != q) {
        _searchController.text = q;
      }
    });
    if (q.isNotEmpty) {
      final provider = Provider.of<CatalogProvider>(context, listen: false);
      provider.addRecentSearch(q);
      provider.searchProducts(q);
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.white,
      leading: IconButton(
        icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.greyBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: const TextStyle(fontSize: 14, color: AppTheme.greyText),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefixIcon: const Icon(PhosphorIcons.magnifyingGlass, color: AppTheme.greyText, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.cancel, color: AppTheme.greyText, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            setState(() {});
          },
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            final itemCount = cartProvider.itemCount;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(PhosphorIcons.shoppingCart, color: AppTheme.black),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                  },
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.black,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFilterSortRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.greyBorder),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.filter_list, size: 16),
                SizedBox(width: 8),
                Text('Filter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.greyBorder),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Text('Sort by: ', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                Text('Relevance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(CatalogProvider provider) {
    if (provider.recentSearches.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: provider.clearRecentSearches,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: AppTheme.black,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.recentSearches.map((search) {
              return GestureDetector(
                onTap: () => _search(search),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.greyBorder),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppTheme.greyText),
                      const SizedBox(width: 6),
                      Text(search, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => provider.removeRecentSearch(search),
                        child: const Icon(Icons.close, size: 14, color: AppTheme.greyText),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(CatalogProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppTheme.black, fontSize: 14, fontFamily: 'San Francisco'),
                children: [
                  const TextSpan(text: 'Results for '),
                  TextSpan(text: '"$_query"', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: ' (${provider.searchResults.length} results)',
                    style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isGridView = true),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isGridView ? AppTheme.black : AppTheme.white,
                    border: Border.all(color: AppTheme.greyBorder),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                  ),
                  child: Icon(Icons.grid_view, size: 18, color: _isGridView ? AppTheme.white : AppTheme.black),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isGridView = false),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: !_isGridView ? AppTheme.black : AppTheme.white,
                    border: Border.all(color: AppTheme.greyBorder),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                  child: Icon(Icons.list, size: 18, color: !_isGridView ? AppTheme.white : AppTheme.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    final width = MediaQuery.of(context).size.width;
    int columns = width > 800 ? 4 : (width > 600 ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.62, // Slightly taller to fit new MOQ/Stock text
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard.fromProduct(
          product: product,
          moqText: 'MOQ: 5 units',
          showStockStatus: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          ),
          onAdd: () {
            if (product.stockQuantity > 0) {
              context.read<CartProvider>().addToCart(product.id, 1);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} added to cart'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Out of stock'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SizedBox(
            height: 340,
            child: ProductCard.fromProduct(
              product: product,
              moqText: 'MOQ: 5 units',
              showStockStatus: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product),
                ),
              ),
              onAdd: () {
                if (product.stockQuantity > 0) {
                  context.read<CartProvider>().addToCart(product.id, 1);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to cart'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestions(CatalogProvider provider) {
    final suggestions = provider.categories.take(5).map((e) => e.name).toList();
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((s) {
            return GestureDetector(
              onTap: () => _search(s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.greyBorder),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s, style: const TextStyle(fontSize: 12)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(CatalogProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppTheme.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIcons.magnifyingGlass, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'No results found for "$_query"',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'We couldn\'t find any products matching your search.\nTry checking the spelling or use different keywords.',
            style: TextStyle(color: AppTheme.greyText, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildSuggestions(provider),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: _buildAppBar(),
      body: Consumer<CatalogProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_query.isEmpty) _buildRecentSearches(provider),
                if (_query.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSuggestions(provider),
                  ),

                if (_query.isNotEmpty && provider.isLoadingProducts)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                if (_query.isNotEmpty && !provider.isLoadingProducts && provider.searchResults.isEmpty)
                  _buildEmptyState(provider),

                if (_query.isNotEmpty && !provider.isLoadingProducts && provider.searchResults.isNotEmpty) ...[
                  _buildRecentSearches(provider),
                  _buildResultsHeader(provider),
                  if (_isGridView) 
                    _buildProductGrid(provider.searchResults)
                  else 
                    _buildProductList(provider.searchResults),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
