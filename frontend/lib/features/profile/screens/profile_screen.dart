import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:gadget_store/features/home/screens/main_screen.dart';
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
import 'package:gadget_store/features/orders/screens/reorder_screen.dart';
import 'package:gadget_store/features/more/providers/notification_provider.dart';
import 'package:gadget_store/features/more/screens/notifications_screen.dart';

enum DashboardState { existing, newBuyer }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DashboardState _currentState = DashboardState.existing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      if (profileProvider.profile == null && !profileProvider.isLoading) {
        profileProvider.fetchProfile();
      }
      if (orderProvider.orders.isEmpty && !orderProvider.isLoading) {
        orderProvider.fetchOrders();
      }
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
              Consumer<OrderProvider>(
                builder: (context, provider, _) {
                  // Only show the "first order" banner if we are certain they have no orders
                  final isTrulyEmpty =
                      provider.orders.isEmpty &&
                      !provider.isLoading &&
                      provider.error == null;
                  return _buildPromoBanners(!isTrulyEmpty);
                },
              ),
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
                                fontWeight: FontWeight.w800,
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
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
                  fontWeight: FontWeight.w800,
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
                  fontWeight: FontWeight.w800,
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
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                );
              },
            ),
            Row(
              children: [
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    final unreadCount = notificationProvider.unreadCount;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: AppTheme.black,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                        ),
                        if (unreadCount > 0)
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
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: AppTheme.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
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
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final recentOrders = orderProvider.orders.take(3).toList();

    return Column(
      children: recentOrders.map((order) {
        int itemCount = order.items.fold(0, (sum, item) => sum + item.quantity);

        String? firstImageUrl;
        if (order.items.isNotEmpty &&
            order.items.first.productDetails != null) {
          final details = order.items.first.productDetails!;
          dynamic imagesData = details['images'];
          if (imagesData is List && imagesData.isNotEmpty) {
            firstImageUrl = imagesData[0].toString();
          } else if (imagesData is String && imagesData.isNotEmpty) {
            try {
              final parsed = jsonDecode(imagesData);
              if (parsed is List && parsed.isNotEmpty) {
                firstImageUrl = parsed[0].toString();
              }
            } catch (_) {}
          } else if (details['image_url'] != null) {
            firstImageUrl = details['image_url'].toString();
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildCompactOrderCard(
            id: '#${order.razorpayOrderId.replaceFirst('order_', '').toUpperCase()}',
            status: order.status.toUpperCase(),
            date:
                '${order.createdAt.day} ${_getMonth(order.createdAt.month)} ${order.createdAt.year}',
            price: '₹${order.amount.toStringAsFixed(0)}',
            items: '$itemCount Items',
            statusColor: _getStatusColor(order.status),
            imageUrl: firstImageUrl,
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

  Widget _buildCompactOrderCard({
    required String id,
    required String status,
    required String date,
    required String price,
    required String items,
    required Color statusColor,
    String? imageUrl,
  }) {
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
            clipBehavior: Clip.hardEdge,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppTheme.black,
                    ),
                  )
                : const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppTheme.black,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order $id',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.black,
                        ),
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
                  '$date • $price',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  items,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
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
    return const SizedBox.shrink(); // Handled by promo banners now
  }

  Widget _buildPromoBanners(bool hasOrders) {
    return SizedBox(
      height: 200,
      child: PageView(
        children: [
          if (!hasOrders)
            _buildBannerItem(
              'Welcome to Gadget Store!',
              'Place your first order',
              'Explore our best products and enjoy a seamless shopping experience.',
              'assets/images/promo_banner_1.png',
              const Color(0xFFFFF7ED),
            )
          else
            _buildBannerItem(
              'Exclusive Deal!',
              'Members Only Sale',
              'As a returning customer, enjoy special access to our newest gadgets.',
              'assets/images/promo_banner_1.png',
              const Color(0xFFFFF7ED),
            ),
          _buildBannerItem(
            'Special Offer!',
            'Get 20% Off',
            'Enjoy exclusive discounts on premium electronics this week only.',
            'assets/images/promo_banner_1.png',
            const Color(0xFFF3F0FF),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(
    String topText,
    String title,
    String subtitle,
    String imagePath,
    Color bgColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  topText,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.black,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainScreen(initialIndex: 0),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                  child: const Text(
                    'Start Shopping',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image_not_supported,
                color: AppTheme.greyText,
              ),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReorderScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionTile(
                Icons.local_shipping_outlined,
                'Track Order',
                'Check delivery status',
                Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
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
          color: color.withValues(alpha: 0.05),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
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
            Icons.settings_outlined,
            'Settings',
            'App preferences',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
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
                      fontWeight: FontWeight.w700,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
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
