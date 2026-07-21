import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/profile/screens/address_screen.dart';
import 'package:gadget_store/features/profile/screens/my_profile_screen.dart';
import 'package:gadget_store/features/profile/screens/settings_screen.dart';
import 'package:gadget_store/features/more/screens/wishlist_screen.dart';
import 'package:gadget_store/features/more/screens/contact_us_screen.dart';
import 'package:gadget_store/features/more/screens/more_menu_screen.dart';
import 'package:gadget_store/features/profile/providers/profile_provider.dart';
import 'package:gadget_store/features/orders/providers/order_provider.dart';
import 'package:gadget_store/features/orders/screens/orders_screen.dart';
import 'package:provider/provider.dart';

enum DashboardState { existing, newBuyer }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  DashboardState _currentState = DashboardState.existing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      if (profileProvider.profile == null && !profileProvider.isLoading) {
        profileProvider.fetchProfile();
      }
      if (orderProvider.orders.isEmpty && !orderProvider.isLoading) {
        orderProvider.fetchOrders();
      }
    });
  }

  void _toggleState() {
    setState(() {
      _currentState = _currentState == DashboardState.existing
          ? DashboardState.newBuyer
          : DashboardState.existing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isExisting = _currentState == DashboardState.existing;

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomHeader(),
              const SizedBox(height: 24),
              if (isExisting)
                _buildExistingHeroCard()
              else
                _buildNewBuyerHeroCard(),
              const SizedBox(height: 32),

              if (isExisting) ...[
                Consumer<OrderProvider>(
                  builder: (context, orderProvider, _) {
                    if (orderProvider.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (orderProvider.orders.isEmpty) {
                      return _buildEmptyOrdersState();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Orders',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.black,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OrdersScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'View All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildRecentOrders(context),
                      ],
                    );
                  },
                ),
              ] else ...[
                _buildEmptyOrdersState(),
              ],

              const SizedBox(height: 32),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(),

              const SizedBox(height: 32),
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildAccountMenu(context),

              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    final isExisting = _currentState == DashboardState.existing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                final firstName =
                    provider.profile?.fullName.split(' ').first ?? 'Guest';
                return Text(
                  'Hi, $firstName 👋',
                  style: const TextStyle(
                    color: AppTheme.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: AppTheme.black,
                      ),
                      onPressed: _toggleState,
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppTheme.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        Text(
          isExisting
              ? 'Welcome back! Glad to see you.'
              : 'Welcome! Let\'s get you started.',
          style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildExistingHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Orders',
                  style: TextStyle(fontSize: 12, color: Colors.green.shade800),
                ),
                const SizedBox(height: 4),
                const Text(
                  '3 Active Orders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '2 delivered in the last 30 days',
                  style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    border: Border.all(color: Colors.green.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View All Orders',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Mock graphic
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.shade200.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 10,
                  child: Icon(
                    Icons.inventory_2,
                    color: Colors.brown.shade300,
                    size: 40,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_bag,
                      color: AppTheme.black,
                      size: 24,
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

  Widget _buildNewBuyerHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Gadget Store!',
                  style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Place your first order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Explore our best products and enjoy a seamless shopping experience.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Start Shopping',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Mock graphic
          Expanded(
            flex: 4,
            child: SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: 0,
                    top: 20,
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.brown.shade300,
                      size: 60,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: AppTheme.black,
                        size: 40,
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

  Widget _buildRecentOrders(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final recentOrders = orderProvider.orders.take(3).toList();

    return Column(
      children: recentOrders.map((order) {
        int itemCount = order.items.fold(0, (sum, item) => sum + item.quantity);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildCompactOrderCard(
            '#${order.razorpayOrderId.replaceFirst('order_', '').toUpperCase()}',
            order.status.toUpperCase(),
            '${order.createdAt.day} ${_getMonth(order.createdAt.month)} ${order.createdAt.year}',
            '₹${order.amount.toStringAsFixed(0)}',
            '$itemCount Items',
            Icons.shopping_bag_outlined,
            _getStatusColor(order.status),
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
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

  Widget _buildCompactOrderCard(
    String id,
    String status,
    String date,
    String price,
    String items,
    IconData icon,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.greyBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Order $id',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$date â€¢ $price',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.greyText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  items,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.greyText, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 60,
            color: AppTheme.greyBorder,
          ),
          const SizedBox(height: 16),
          const Text(
            'No orders yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'When you place your first order,\nit will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.greyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.black,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                Icons.refresh,
                'Reorder',
                'Buy again easily',
                Colors.blue,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionTile(
                Icons.local_shipping_outlined,
                'Track Order',
                'Check delivery status',
                Colors.green,
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionTile(
                Icons.favorite_border,
                'Wishlist',
                'Your saved items',
                Colors.red,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionTile(
                Icons.headphones_outlined,
                'Support',
                'Get help & support',
                Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.greyText,
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

  Widget _buildAccountMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.person_outline,
            'Profile',
            'Manage your personal info',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyProfileScreen()),
              );
            },
          ),
          const Divider(color: AppTheme.greyBorder, height: 1, indent: 56),
          _buildMenuItem(
            Icons.location_on_outlined,
            'Addresses',
            'Manage saved addresses',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddressScreen()),
              );
            },
          ),
          const Divider(color: AppTheme.greyBorder, height: 1, indent: 56),
          _buildMenuItem(
            Icons.credit_card_outlined,
            'Payment Methods',
            'Cards, UPI & more',
            () {},
          ),
          const Divider(color: AppTheme.greyBorder, height: 1, indent: 56),
          _buildMenuItem(
            Icons.settings_outlined,
            'Settings',
            'App preferences',
            () {},
          ),
          const Divider(color: AppTheme.greyBorder, height: 1, indent: 56),
          _buildMenuItem(
            Icons.more_horiz,
            'More Options',
            'About, Policies & Logout',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MoreMenuScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.black, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.greyText, size: 20),
          ],
        ),
      ),
    );
  }
}
