import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/features/orders/providers/order_provider.dart';
import 'package:gadget_world/features/orders/models/order.dart';
import 'package:gadget_world/features/cart/providers/cart_provider.dart';
import 'package:gadget_world/features/checkout/screens/cart_screen.dart';
import 'package:gadget_world/features/orders/screens/orders_screen.dart';
import 'package:intl/intl.dart';
import 'package:gadget_world/features/home/screens/main_screen.dart';
import 'package:gadget_world/features/products/screens/categories_screen.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class ReorderScreen extends StatefulWidget {
  const ReorderScreen({super.key});

  @override
  State<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends State<ReorderScreen> {
  final formatCurrency = NumberFormat.simpleCurrency(
    name: 'INR',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  void _reorderItem(OrderItem item) async {
    try {
      await Provider.of<CartProvider>(context, listen: false).addToCart(
        item.productId,
        item.quantity, // Use original order quantity
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added to cart')));

      // Redirect to Cart Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.greyBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reorder',
          style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null && orderProvider.orders.isEmpty) {
            return Center(child: Text('Error: ${orderProvider.error}'));
          }

          // Flatten items
          final List<Map<String, dynamic>> allPurchasedItems = [];
          for (var order in orderProvider.orders) {
            for (var item in order.items) {
              allPurchasedItems.add({'order': order, 'item': item});
            }
          }

          if (allPurchasedItems.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBanner(),
                  const SizedBox(height: 24),
                  const Text(
                    'Buy Again',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Items you've purchased before, ready to order again.",
                    style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                  ),
                  const SizedBox(height: 16),
                  ...allPurchasedItems.map((entry) {
                    final order = entry['order'] as Order;
                    final item = entry['item'] as OrderItem;
                    return _buildOrderItemCard(order, item);
                  }),
                  const SizedBox(height: 16),
                  _buildFooter(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopBanner(),
            const SizedBox(height: 64),
            // Empty State Graphic
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  PhosphorIcons.package,
                  size: 100,
                  color: Colors.green.shade200,
                ),
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIcons.arrowsClockwise,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                ),
                Positioned(
                  top: -20,
                  right: 0,
                  child: Icon(
                    Icons.send,
                    color: Colors.green.shade300,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'No items to reorder yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "You haven't placed any orders yet.\nOnce you do, your past purchases will\nappear here for easy reordering.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.greyText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(initialIndex: 1),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 64),
            // Bottom section: Explore our categories
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIcons.squaresFour,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore our categories',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find the best gadgets for you.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CategoriesScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Browse Categories',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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

  Widget _buildTopBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.arrowsClockwise,
              color: Colors.green.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quickly buy again',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Reorder your previous purchases\nin just a tap.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          // Mock graphic representation
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(
                  PhosphorIcons.shoppingBagFill,
                  color: Colors.green.shade700,
                  size: 36,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      PhosphorIcons.package,
                      color: Colors.brown,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemCard(Order order, OrderItem item) {
    final details = item.productDetails ?? {};
    final String name = details['name'] ?? 'Unknown Product';
    final String category = details['category_name'] ?? 'Product';

    // Attempt to get an image
    String? imageUrl;
    if (details['images'] != null) {
      if (details['images'] is List && (details['images'] as List).isNotEmpty) {
        imageUrl = (details['images'] as List).first.toString();
      } else if (details['images'] is String) {
        final str = details['images'] as String;
        if (str.startsWith('{') && str.endsWith('}')) {
          final parts = str.substring(1, str.length - 1).split(',');
          if (parts.isNotEmpty) {
            imageUrl = parts.first.trim().replaceAll('"', '');
          }
        }
      }
    }

    // Format date
    final String dateStr = DateFormat(
      'dd MMM yyyy',
    ).format(order.createdAt.toLocal());

    // Status color
    Color statusColor = Colors.orange;
    if (order.status.toLowerCase() == 'delivered') {
      statusColor = Colors.green;
    } else if (order.status.toLowerCase() == 'cancelled') {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header: Date and Status
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      PhosphorIcons.calendar,
                      size: 14,
                      color: AppTheme.greyText,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.status.toLowerCase() == 'delivered'
                          ? 'Delivered on $dateStr'
                          : 'Ordered on $dateStr',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  order.status.substring(0, 1).toUpperCase() +
                      order.status.substring(1),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.greyBorder),
          // Body: Product Info and Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.greyBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  PhosphorIcons.imageBroken,
                                  color: AppTheme.greyText,
                                ),
                          ),
                        )
                      : const Icon(
                          PhosphorIcons.image,
                          color: AppTheme.greyText,
                        ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatCurrency.format(item.amount)}  •  Qty: ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Reorder Button
                OutlinedButton.icon(
                  onPressed: () => _reorderItem(item),
                  icon: const Icon(
                    PhosphorIcons.arrowsClockwise,
                    size: 16,
                    color: Colors.green,
                  ),
                  label: const Text(
                    'Reorder',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Can't find what you're looking for?",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'View all your previous purchases in your Order History.',
                  style: TextStyle(fontSize: 10, color: AppTheme.greyText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
            child: const Text(
              'View Order History',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
