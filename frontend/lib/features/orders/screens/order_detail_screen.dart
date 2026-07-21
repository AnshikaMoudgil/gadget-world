import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';

import 'package:gadget_store/features/orders/models/order.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isTimelineExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16),
                    _buildStatusCard(),
                    const SizedBox(height: 24),
                    Text(
                      'Items (${widget.order.items.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                    const SizedBox(height: 24),
                    _buildDeliveryTimeline(),
                    const SizedBox(height: 24),
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAddressCard(),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildPaymentInfoCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildOrderSummaryCard()),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildActionTile(
                      Icons.download_outlined,
                      'Download Invoice',
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      Icons.local_shipping_outlined,
                      'Track Package',
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      Icons.assignment_return_outlined,
                      'Return or Replace',
                    ),
                    const SizedBox(height: 48), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: const Text(
                'Order Detail',
                style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.headphones_outlined,
                  color: AppTheme.black,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppTheme.black),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = _getMonth(date.month);
    final year = date.year;
    int hour = date.hour;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute $ampm';
  }

  Widget _buildHeaderCard() {
    final orderId = widget.order.razorpayOrderId.replaceFirst('order_', '').toUpperCase();
    final date = _formatDate(widget.order.createdAt);
    
    Color statusColor;
    Color statusBgColor;
    switch (widget.order.status.toLowerCase()) {
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #$orderId',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Placed on $date',
                style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.order.status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = widget.order.status.toLowerCase();
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusDesc;
    
    switch (status) {
      case 'delivered':
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.inventory_2;
        statusTitle = '${status == 'completed' ? 'Completed' : 'Delivered'} on ${_formatDate(widget.order.createdAt.add(const Duration(days: 2)))}';
        statusDesc = 'Your order has been ${status == 'completed' ? 'completed' : 'delivered'} successfully.';
        break;
      case 'shipped':
        statusColor = Colors.blue;
        statusIcon = Icons.local_shipping;
        statusTitle = 'Shipped on ${_formatDate(widget.order.createdAt.add(const Duration(days: 1)))}';
        statusDesc = 'Your order is on the way.';
        break;
      case 'cancelled':
        statusColor = AppTheme.greyText;
        statusIcon = Icons.cancel;
        statusTitle = 'Cancelled';
        statusDesc = 'Your order has been cancelled.';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        statusTitle = 'Confirmed on ${_formatDate(widget.order.createdAt)}';
        statusDesc = 'Your order is confirmed and being processed.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppTheme.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusDesc,
                  style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
                ),
                if (status == 'delivered') ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'View proof of delivery',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: statusColor),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(statusIcon, color: statusColor.withValues(alpha: 0.5), size: 40),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: AppTheme.white,
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

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: widget.order.items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final details = item.productDetails;
          
          final title = details?['name'] ?? 'Product';
          final subtitle = details?['category'] ?? 'Category';
          
          return Column(
            children: [
              _buildOrderItem(
                title,
                subtitle,
                item.quantity,
                '₹${item.amount.toStringAsFixed(0)}',
                item.quantity > 1 ? '₹${(item.amount / item.quantity).toStringAsFixed(0)} each' : null,
                Icons.shopping_bag_outlined,
              ),
              if (idx < widget.order.items.length - 1)
                const Divider(color: AppTheme.greyBorder, height: 24),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderItem(
    String title,
    String subtitle,
    int qty,
    String price,
    String? unitPrice,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(width: 12),
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
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
              ),
              const SizedBox(height: 4),
              Text(
                'Qty: $qty',
                style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            if (unitPrice != null) ...[
              const SizedBox(height: 4),
              Text(
                unitPrice,
                style: const TextStyle(fontSize: 10, color: AppTheme.greyText),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryTimeline() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isTimelineExpanded = !_isTimelineExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Delivery Timeline',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Delivered on 11 Jul 2025, 04:45 PM',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isTimelineExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.black,
                  ),
                ],
              ),
            ),
          ),
          if (_isTimelineExpanded) ...[
            const Divider(color: AppTheme.greyBorder, height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildTimelineItem(
                    'Order Placed',
                    '09 Jul 2025, 10:41 AM',
                    true,
                    false,
                  ),
                  _buildTimelineItem(
                    'Order Confirmed',
                    '09 Jul 2025, 11:30 AM',
                    true,
                    false,
                  ),
                  _buildTimelineItem(
                    'Packed',
                    '10 Jul 2025, 09:15 AM',
                    true,
                    false,
                  ),
                  _buildTimelineItem(
                    'Shipped',
                    'AWB: 1234567890\nCourier: Delhivery',
                    true,
                    false,
                    trailingDate: '10 Jul 2025, 07:40 PM',
                  ),
                  _buildTimelineItem(
                    'Reached Delhi Hub',
                    '11 Jul 2025, 06:40 AM',
                    true,
                    false,
                  ),
                  _buildTimelineItem(
                    'Out for Delivery',
                    '11 Jul 2025, 09:15 AM',
                    true,
                    false,
                  ),
                  _buildTimelineItem(
                    'Delivered',
                    '11 Jul 2025, 04:45 PM',
                    true,
                    true,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    bool isCompleted,
    bool isActive, {
    bool isLast = false,
    String? trailingDate,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : AppTheme.white,
                border: Border.all(
                  color: isCompleted ? Colors.green : AppTheme.greyBorder,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isActive
                  ? const Center(
                      child: Icon(Icons.check, size: 10, color: AppTheme.white),
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : AppTheme.greyBorder,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: isLast ? 0 : 24.0,
            ), // Spacing for next item
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? AppTheme.black
                              : AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailingDate != null)
                  Text(
                    trailingDate,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.greyText,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, color: AppTheme.black, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Rohit Sharma',
                      style: TextStyle(
                        fontSize: 14,
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
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '456, Lajpat Nagar, Part 2,\nNear Metro Station, New Delhi - 110024',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '+91 98765 43210',
                  style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    final date = _formatDate(widget.order.createdAt);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.flash_on, size: 14, color: AppTheme.black),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'Razorpay (UPI)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Paid',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Paid on $date',
            style: const TextStyle(fontSize: 10, color: AppTheme.greyText),
          ),
          const SizedBox(height: 16),
          const Text(
            'Amount',
            style: TextStyle(fontSize: 12, color: AppTheme.greyText),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${widget.order.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final itemCount = widget.order.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final subtotal = widget.order.items.fold<double>(0, (sum, item) => sum + item.amount);
    
    // Reverse calculate shipping and discount to match total. 
    // This assumes if amount > 50000 there is 0 shipping, otherwise 49.
    final shipping = subtotal > 50000 ? 0.0 : 49.0;
    
    // We can infer the discount if the subtotal + shipping > total
    // But since the API returns amount as total, let's just make it simple
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Subtotal ($itemCount items)',
                  style: const TextStyle(fontSize: 10, color: AppTheme.greyText),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '₹${subtotal.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 10, color: AppTheme.black),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Shipping Fee',
                  style: TextStyle(fontSize: 10, color: AppTheme.greyText),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '₹${shipping.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 10, color: AppTheme.black),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: AppTheme.greyBorder, height: 1),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '₹${widget.order.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '(Inclusive of all taxes)',
            style: TextStyle(fontSize: 8, color: AppTheme.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.black, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.greyText, size: 20),
        ],
      ),
    );
  }
}
