import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';
import 'package:gadget_store/features/orders/screens/order_detail_screen.dart';
import 'package:gadget_store/features/orders/providers/order_provider.dart';
import 'package:gadget_store/features/orders/models/order.dart';
import 'package:provider/provider.dart';

enum OrdersState { loaded, loading, empty }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      if (orderProvider.orders.isEmpty && !orderProvider.isLoading) {
        orderProvider.fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'My Orders',
                  style: TextStyle(
                    color: AppTheme.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Track and manage all your orders',
                  style: TextStyle(color: AppTheme.greyText, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: AppTheme.black),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.filter_alt_outlined,
                  color: AppTheme.black,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        final isLoading = orderProvider.isLoading;
        final orders = orderProvider.orders;

        if (isLoading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(true),
              const SizedBox(height: 16),
              Expanded(child: _buildLoadingList()),
            ],
          );
        }

        if (orderProvider.error != null) {
          return Center(
            child: Text(
              'Error: ${orderProvider.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (orders.isEmpty) {
          return _buildEmptyState();
        }

        final filteredOrders = _selectedFilter == 'All'
            ? orders
            : orders
                  .where(
                    (o) =>
                        o.status.toLowerCase() == _selectedFilter.toLowerCase(),
                  )
                  .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(false),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Orders (${filteredOrders.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        'No $_selectedFilter orders found.',
                        style: const TextStyle(color: AppTheme.greyText),
                      ),
                    )
                  : _buildLoadedList(filteredOrders),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilters(bool isLoading) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip('All', isLoading: isLoading),
          _buildFilterChip('Pending', isLoading: isLoading),
          _buildFilterChip('Confirmed', isLoading: isLoading),
          _buildFilterChip('Completed', isLoading: isLoading),
          _buildFilterChip('Shipped', isLoading: isLoading),
          _buildFilterChip('Delivered', isLoading: isLoading),
          _buildFilterChip('Cancelled', isLoading: isLoading),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isLoading = false}) {
    final isSelected = _selectedFilter == label;

    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(right: 8),
        width: 80,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.greyBackground,
          borderRadius: BorderRadius.circular(18),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (_selectedFilter != label) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.black : AppTheme.white,
          border: Border.all(
            color: isSelected ? AppTheme.black : AppTheme.greyBorder,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.white : AppTheme.black,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedList(List<Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final itemCount = order.items.fold<int>(
          0,
          (int sum, item) => sum + item.quantity,
        );

        return _buildOrderItemCard(
          order: order,
          id: '#${order.razorpayOrderId.replaceFirst('order_', '').toUpperCase()}',
          status: order.status.toUpperCase(),
          date:
              '${order.createdAt.day} ${_getMonth(order.createdAt.month)} ${order.createdAt.year}',
          price: '₹${order.amount.toStringAsFixed(0)}',
          items: '$itemCount Items',
          icon: Icons.shopping_bag_outlined,
        );
      },
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildOrderItemCard({
    required Order order,
    required String id,
    required String date,
    required String status,
    required String items,
    required String price,
    required IconData icon,
  }) {
    Color statusColor;
    Color statusBgColor;

    switch (status.toLowerCase()) {
      case 'delivered':
        statusColor = Colors.green;
        statusBgColor = Colors.green.shade50;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.shade50;
        break;
      case 'confirmed':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.shade50;
        break;
      case 'cancelled':
        statusColor = AppTheme.greyText;
        statusBgColor = AppTheme.greyBackground;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusBgColor = Colors.green.shade50;
        break;
      default:
        statusColor = AppTheme.black;
        statusBgColor = AppTheme.greyBackground;
    }

    // Capture context for navigation
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: AppTheme.greyBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.greyBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.black, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order $id',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            items,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.black,
                      size: 20,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.greyBorder.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image shimmer
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.greyBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer
                    Container(
                      width: 150,
                      height: 14,
                      color: AppTheme.greyBackground,
                    ),
                    const SizedBox(height: 8),
                    // Date shimmer
                    Container(
                      width: 120,
                      height: 12,
                      color: AppTheme.greyBackground,
                    ),
                    const SizedBox(height: 12),
                    // Status and items shimmer
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.greyBackground,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 12,
                          color: AppTheme.greyBackground,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price chevron shimmer
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.greyBorder,
                    size: 20,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 50,
                    height: 14,
                    color: AppTheme.greyBackground,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Graphic
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative stars
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Icon(
                      Icons.star,
                      size: 12,
                      color: AppTheme.greyBorder,
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 30,
                    child: Icon(
                      Icons.star,
                      size: 16,
                      color: AppTheme.greyBorder,
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 10,
                    child: Icon(
                      Icons.star,
                      size: 14,
                      color: AppTheme.greyBorder,
                    ),
                  ),

                  // Clipboard
                  Container(
                    width: 100,
                    height: 130,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      border: Border.all(color: AppTheme.greyBorder, width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 8,
                          color: AppTheme.greyBorder,
                          margin: const EdgeInsets.only(bottom: 12),
                        ),
                        Container(
                          width: 60,
                          height: 8,
                          color: AppTheme.greyBorder,
                          margin: const EdgeInsets.only(bottom: 12),
                        ),
                        Container(
                          width: 50,
                          height: 8,
                          color: AppTheme.greyBorder,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 15,
                    child: Container(
                      width: 40,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.greyBorder,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  // Shopping Bag
                  Positioned(
                    bottom: 0,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.greyBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.greyBorder),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.shopping_bag,
                          size: 40,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Looks like you haven\'t placed any orders.\nWhat are you waiting for?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.greyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // If running in main bottom nav, this should theoretically
                  // just change the tab index. We'll pop or push replacement for demo.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.black,
                  foregroundColor: AppTheme.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shopping_bag_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Start Shopping',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
