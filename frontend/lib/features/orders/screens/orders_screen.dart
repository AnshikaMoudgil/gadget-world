import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';
import 'package:gadget_store/features/orders/screens/order_detail_screen.dart';
import 'package:gadget_store/features/orders/providers/order_provider.dart';
import 'package:gadget_store/features/orders/models/order.dart';
import 'package:gadget_store/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

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
              children: [
                Row(
                  children: [
                    if (Navigator.canPop(context))
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            PhosphorIcons.arrowLeft,
                            color: AppTheme.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    const Text(
                      'My Orders',
                      style: TextStyle(
                        color: AppTheme.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track and manage all your orders',
                  style: TextStyle(color: AppTheme.greyText, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  PhosphorIcons.magnifyingGlass,
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
          final errorText = orderProvider.error!.toLowerCase();
          final isAuthError =
              errorText.contains('expired') ||
              errorText.contains('authentication failed') ||
              errorText.contains('403');

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAuthError ? Icons.lock_clock : Icons.error_outline,
                    size: 48,
                    color: AppTheme.greyText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isAuthError
                        ? 'Your session has expired.'
                        : 'Something went wrong.',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAuthError
                        ? 'Please log in again to view your orders.'
                        : orderProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.greyText),
                  ),
                  if (isAuthError) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        await authProvider.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.black,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Log In Again'),
                    ),
                  ],
                ],
              ),
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
      itemCount: orders.length + 1,
      itemBuilder: (context, index) {
        if (index == orders.length) {
          return Container(
            margin: const EdgeInsets.only(top: 16, bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8), // Very light grey
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  PhosphorIcons.package,
                  color: Colors.brown,
                  size: 28,
                ), // Package icon
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Can\'t find your order?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Make sure you\'re using the email ID you placed the order with.',
                        style: TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final order = orders[index];
        final itemCount = order.items.fold<int>(
          0,
          (int sum, item) => sum + item.quantity,
        );

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

        String productName = 'Order';
        if (order.items.isNotEmpty &&
            order.items.first.productDetails != null) {
          final details = order.items.first.productDetails!;
          if (details['name'] != null) {
            productName = details['name'].toString();
            if (order.items.length > 1) {
              productName += ' +${order.items.length - 1} more';
            }
          }
        }

        final shortId = order.id.split('-').first.toUpperCase().substring(0, 6);

        return _buildOrderItemCard(
          order: order,
          title: productName,
          shortId: '#$shortId',
          status: order.status.toUpperCase(),
          date:
              '${order.createdAt.day} ${_getMonth(order.createdAt.month)} ${order.createdAt.year}, ${_formatTime(order.createdAt)}',
          price: '₹${order.amount.toStringAsFixed(0)}',
          items: itemCount == 1 ? '1 Item' : '$itemCount Items',
          imageUrl: firstImageUrl,
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    String hour = time.hour > 12
        ? (time.hour - 12).toString().padLeft(2, '0')
        : time.hour.toString().padLeft(2, '0');
    if (hour == '00') hour = '12';
    String minute = time.minute.toString().padLeft(2, '0');
    String ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
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
    required String title,
    required String shortId,
    required String date,
    required String status,
    required String items,
    required String price,
    String? imageUrl,
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
              border: Border.all(color: const Color(0xFFEEEEEE)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                PhosphorIcons.shoppingBag,
                                color: AppTheme.greyText,
                                size: 30,
                              ),
                        )
                      : const Icon(
                          PhosphorIcons.shoppingBag,
                          color: AppTheme.greyText,
                          size: 30,
                        ),
                ),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Order $shortId • $date',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(width: 12),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      PhosphorIcons.caretRight,
                      color: AppTheme.greyText,
                      size: 20,
                    ),
                    const SizedBox(height: 24), // Push price down
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
            color: AppTheme.white,
            border: Border.all(color: const Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image shimmer
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
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
                      width: 180,
                      height: 14,
                      color: const Color(0xFFF0F0F0),
                    ),
                    const SizedBox(height: 12),
                    // Date shimmer
                    Container(
                      width: 130,
                      height: 12,
                      color: const Color(0xFFF0F0F0),
                    ),
                    const SizedBox(height: 16),
                    // Status and items shimmer
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 40,
                          height: 12,
                          color: const Color(0xFFF0F0F0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Price chevron shimmer
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    PhosphorIcons.caretRight,
                    color: Color(0xFFEEEEEE),
                    size: 20,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 50,
                    height: 14,
                    color: const Color(0xFFF0F0F0),
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
              width: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Decorative stars
                  const Positioned(
                    top: 20,
                    left: 20,
                    child: Icon(Icons.star, size: 12, color: Color(0xFFE0E0E0)),
                  ),
                  const Positioned(
                    top: 50,
                    right: 30,
                    child: Icon(Icons.star, size: 16, color: Color(0xFFE0E0E0)),
                  ),
                  const Positioned(
                    bottom: 40,
                    left: 10,
                    child: Icon(Icons.star, size: 14, color: Color(0xFFE0E0E0)),
                  ),
                  // Clipboard
                  Container(
                    width: 100,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8), // Light grey
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        _buildCheckListItem(),
                        _buildCheckListItem(),
                        _buildCheckListItem(),
                      ],
                    ),
                  ),
                  // Top clip of clipboard
                  Positioned(
                    top: 15,
                    child: Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Shopping Bag
                  Positioned(
                    bottom: 0,
                    right: 10,
                    child: Container(
                      width: 70,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: -10,
                            child: Container(
                              width: 30,
                              height: 20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                  width: 3,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.flash_on,
                            size: 30,
                            color: AppTheme.black,
                          ), // Gadget World logo equivalent
                        ],
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 1),
                    ),
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
                    Icon(Icons.lock_outline, size: 18),
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

  Widget _buildCheckListItem() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
