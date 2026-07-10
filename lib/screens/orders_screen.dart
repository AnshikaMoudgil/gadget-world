import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'main_screen.dart';
import 'order_detail_screen.dart';

enum OrdersState { loaded, loading, empty }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  OrdersState _currentState = OrdersState.loaded;

  void _cycleState() {
    setState(() {
      if (_currentState == OrdersState.loaded) {
        _currentState = OrdersState.loading;
      } else if (_currentState == OrdersState.loading) {
        _currentState = OrdersState.empty;
      } else {
        _currentState = OrdersState.loaded;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false, // In main bottom nav, usually no back button
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('My Orders', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text('Track and manage all your orders', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: AppTheme.black), onPressed: () {}),
        IconButton(icon: const Icon(Icons.filter_alt_outlined, color: AppTheme.black), onPressed: () {}),
        IconButton(icon: const Icon(Icons.change_circle_outlined, color: AppTheme.greyText), onPressed: _cycleState, tooltip: 'Cycle UI State'),
      ],
    );
  }

  Widget _buildBody() {
    if (_currentState == OrdersState.empty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilters(),
        const SizedBox(height: 16),
        if (_currentState == OrdersState.loaded)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text('Orders (6)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.black)),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: _currentState == OrdersState.loaded ? _buildLoadedList() : _buildLoadingList(),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final isLoading = _currentState == OrdersState.loading;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildFilterChip('All', isSelected: !isLoading, isLoading: isLoading),
          _buildFilterChip('Pending', isLoading: isLoading),
          _buildFilterChip('Confirmed', isLoading: isLoading),
          _buildFilterChip('Shipped', isLoading: isLoading),
          _buildFilterChip('Delivered', isLoading: isLoading),
          _buildFilterChip('Cancelled', isLoading: isLoading),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false, bool isLoading = false}) {
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

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.black : AppTheme.white,
        border: Border.all(color: isSelected ? AppTheme.black : AppTheme.greyBorder),
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
    );
  }

  Widget _buildLoadedList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      children: [
        _buildOrderItemCard(
          id: '#GS1234567890',
          date: '09 Jul 2025, 10:41 AM',
          status: 'Delivered',
          items: '3 Items',
          price: '₹7,405',
          icon: Icons.headphones,
        ),
        _buildOrderItemCard(
          id: '#GS1234567889',
          date: '07 Jul 2025, 06:22 PM',
          status: 'Shipped',
          items: '2 Items',
          price: '₹5,998',
          icon: Icons.watch,
        ),
        _buildOrderItemCard(
          id: '#GS1234567888',
          date: '05 Jul 2025, 02:10 PM',
          status: 'Confirmed',
          items: '1 Item',
          price: '₹1,199',
          icon: Icons.battery_charging_full,
        ),
        _buildOrderItemCard(
          id: '#GS1234567887',
          date: '02 Jul 2025, 11:30 AM',
          status: 'Cancelled',
          items: '2 Items',
          price: '₹2,598',
          icon: Icons.earbuds,
        ),
        _buildOrderItemCard(
          id: '#GS1234567886',
          date: '30 Jun 2025, 09:15 PM',
          status: 'Delivered',
          items: '1 Item',
          price: '₹1,999',
          icon: Icons.earbuds_battery,
        ),
        _buildOrderItemCard(
          id: '#GS1234567885',
          date: '28 Jun 2025, 04:45 PM',
          status: 'Delivered',
          items: '1 Item',
          price: '₹2,499',
          icon: Icons.speaker,
        ),
        const SizedBox(height: 16),
        _buildHelpCard(),
      ],
    );
  }

  Widget _buildOrderItemCard({
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
      default:
        statusColor = AppTheme.black;
        statusBgColor = AppTheme.greyBackground;
    }

    // Capture context for navigation
    return Builder(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderDetailScreen()));
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
                Text('Order $id', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                    const SizedBox(width: 8),
                    Text(items, style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.chevron_right, color: AppTheme.black, size: 20),
              const SizedBox(height: 16),
              Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
            ],
          ),
        ],
      ),
    ),
    );
      },
    );
  }
  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.inventory_2, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Can\'t find your order?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                SizedBox(height: 4),
                Text('Make sure you\'re using the email ID you placed the order with.', style: TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
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
            border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image shimmer
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title shimmer
                    Container(width: 150, height: 14, color: AppTheme.greyBackground),
                    const SizedBox(height: 8),
                    // Date shimmer
                    Container(width: 120, height: 12, color: AppTheme.greyBackground),
                    const SizedBox(height: 12),
                    // Status and items shimmer
                    Row(
                      children: [
                        Container(width: 60, height: 20, decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 8),
                        Container(width: 40, height: 12, color: AppTheme.greyBackground),
                      ],
                    ),
                  ],
                ),
              ),
              // Price chevron shimmer
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(Icons.chevron_right, color: AppTheme.greyBorder, size: 20),
                  const SizedBox(height: 16),
                  Container(width: 50, height: 14, color: AppTheme.greyBackground),
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
                  Positioned(top: 20, left: 20, child: Icon(Icons.star, size: 12, color: AppTheme.greyBorder)),
                  Positioned(top: 50, right: 30, child: Icon(Icons.star, size: 16, color: AppTheme.greyBorder)),
                  Positioned(bottom: 40, left: 10, child: Icon(Icons.star, size: 14, color: AppTheme.greyBorder)),
                  
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
                        Container(width: 40, height: 8, color: AppTheme.greyBorder, margin: const EdgeInsets.only(bottom: 12)),
                        Container(width: 60, height: 8, color: AppTheme.greyBorder, margin: const EdgeInsets.only(bottom: 12)),
                        Container(width: 50, height: 8, color: AppTheme.greyBorder),
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
                        child: Icon(Icons.shopping_bag, size: 40, color: AppTheme.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text('No orders yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.black)),
            const SizedBox(height: 12),
            const Text(
              'Looks like you haven\'t placed any orders.\nWhat are you waiting for?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.greyText, height: 1.5),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shopping_bag_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Start Shopping', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
