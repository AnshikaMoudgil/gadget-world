import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/orders/models/order.dart';
import 'package:gadget_store/features/orders/utils/invoice_generator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:gadget_store/core/widgets/optimized_network_image.dart';

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
                      onTap: () {
                        InvoiceGenerator.generateAndPrintInvoice(widget.order);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      Icons.verified_user_outlined,
                      'Need help? Contact support',
                      onTap: () {},
                    ),
                    const SizedBox(height: 48),
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
            icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
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
                icon: const Icon(
                  PhosphorIcons.dotsThreeVertical,
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

  String _formatDate(DateTime date) {
    date = date.toLocal();
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
    String orderId = widget.order.razorpayOrderId;
    if (orderId.isEmpty) {
      orderId = widget.order.id.length > 8
          ? widget.order.id.substring(0, 8).toUpperCase()
          : widget.order.id.toUpperCase();
    } else {
      orderId = orderId.replaceFirst('order_', '').toUpperCase();
    }
    final date = _formatDate(widget.order.createdAt);

    Color statusColor;
    switch (widget.order.status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'shipped':
        statusColor = Colors.blue;
        break;
      case 'confirmed':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = AppTheme.greyText;
        break;
      default:
        statusColor = AppTheme.black;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
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
    String statusTitle;
    String statusDesc;

    switch (status) {
      case 'delivered':
      case 'completed':
        statusColor = Colors.green;
        statusTitle =
            'Delivered on ${_formatDate(widget.order.createdAt.add(const Duration(days: 2)))}';
        statusDesc = 'Your order has been delivered successfully.';
        break;
      case 'shipped':
        statusColor = Colors.blue;
        statusTitle =
            'Shipped on ${_formatDate(widget.order.createdAt.add(const Duration(days: 1)))}';
        statusDesc = 'Your order is on the way.';
        break;
      case 'cancelled':
        statusColor = AppTheme.greyText;
        statusTitle = 'Cancelled';
        statusDesc = 'Your order has been cancelled.';
        break;
      default:
        statusColor = Colors.orange;
        statusTitle = 'Confirmed on ${_formatDate(widget.order.createdAt)}';
        statusDesc = 'Your order is confirmed and being processed.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppTheme.white, size: 20),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
                if (status == 'delivered' || status == 'completed') ...[
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
                      Icon(
                        PhosphorIcons.caretRight,
                        size: 16,
                        color: statusColor,
                      ),
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
                Icon(
                  PhosphorIcons.package,
                  color: statusColor.withValues(alpha: 0.5),
                  size: 40,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: AppTheme.white,
                      ),
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
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: widget.order.items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final details = item.productDetails;

          final title = details?['name'] ?? 'Product';
          final subtitle = details?['category'] ?? 'Category';
          String? imageUrl;
          if (details != null) {
            if (details['images'] != null &&
                (details['images'] as List).isNotEmpty) {
              imageUrl = (details['images'] as List).first as String;
            } else {
              imageUrl = details['image_url'] as String?;
            }
          }
          return Column(
            children: [
              _buildOrderItem(
                title,
                subtitle,
                item.quantity,
                '₹${item.amount.toStringAsFixed(0)}',
                item.quantity > 1
                    ? '₹${(item.amount / item.quantity).toStringAsFixed(0)} each'
                    : null,
                imageUrl,
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
    String? imageUrl,
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
          child: imageUrl != null && imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: OptimizedNetworkImage(
                    imageUrl: imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(PhosphorIcons.shoppingBag, color: AppTheme.black),
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
    final status = widget.order.status.toLowerCase();
    final isDelivered = status == 'delivered' || status == 'completed';
    final isShipped = isDelivered || status == 'shipped';
    final isPacked = isShipped || status == 'packed';
    final isConfirmed = isPacked || status == 'confirmed';

    String displayDate = '';
    if (isDelivered) {
      displayDate = widget.order.deliveredAt != null
          ? 'Delivered on ${_formatDate(widget.order.deliveredAt!)}'
          : 'Delivered';
    } else if (isShipped) {
      displayDate = widget.order.shippedAt != null
          ? 'Shipped on ${_formatDate(widget.order.shippedAt!)}'
          : 'Shipped';
    } else {
      displayDate = 'Pending delivery';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
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
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.5),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Timeline',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayDate,
                          style: const TextStyle(
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
                    _formatDate(widget.order.createdAt),
                    true,
                    status == 'pending_payment' || status == 'pending',
                  ),
                  _buildTimelineItem(
                    'Order Confirmed',
                    isConfirmed
                        ? _formatDate(
                            widget.order.createdAt.add(
                              const Duration(minutes: 45),
                            ),
                          )
                        : 'Processing...',
                    isConfirmed,
                    status == 'confirmed',
                  ),
                  _buildTimelineItem(
                    'Packed',
                    isPacked ? 'Packed for shipping' : 'Waiting to pack',
                    isPacked,
                    status == 'packed',
                  ),
                  _buildTimelineItem(
                    'Shipped',
                    isShipped
                        ? 'AWB: 1234567890\nCourier: Delhivery'
                        : 'Waiting to ship',
                    isShipped,
                    status == 'shipped',
                    trailingDate: widget.order.shippedAt != null
                        ? _formatDate(widget.order.shippedAt!)
                        : null,
                  ),
                  _buildTimelineItem(
                    'Reached Delhi Hub',
                    isShipped
                        ? _formatDate(
                            widget.order.createdAt.add(const Duration(days: 2)),
                          )
                        : 'Pending',
                    isShipped,
                    false,
                  ),
                  _buildTimelineItem(
                    'Out for Delivery',
                    isDelivered
                        ? _formatDate(
                            widget.order.createdAt.add(
                              const Duration(days: 2, hours: 4),
                            ),
                          )
                        : 'Pending',
                    isDelivered,
                    false,
                  ),
                  _buildTimelineItem(
                    'Delivered',
                    isDelivered
                        ? (widget.order.deliveredAt != null
                              ? _formatDate(widget.order.deliveredAt!)
                              : 'Delivered')
                        : 'Pending delivery',
                    isDelivered,
                    isDelivered,
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
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.white,
                border: Border.all(
                  color: isCompleted ? Colors.green : AppTheme.greyBorder,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isActive || isCompleted
                  ? Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                      ),
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
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(
              color: AppTheme.greyBorder.withValues(alpha: 0.3),
            ),
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
                    if (widget.order.shippingAddress != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.order.shippingAddress!.recipientName,
                                style: const TextStyle(
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
                                  ),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.order.shippingAddress!.addressLine1}, ${widget.order.shippingAddress!.addressLine2 != null ? '${widget.order.shippingAddress!.addressLine2}, ' : ''}\n${widget.order.shippingAddress!.city}, ${widget.order.shippingAddress!.state} - ${widget.order.shippingAddress!.postalCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+91 ${widget.order.shippingAddress!.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ] else
                      const Text(
                        'No shipping address available.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyText,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfoCard() {
    final date = _formatDate(widget.order.createdAt);
    final isPaid = widget.order.status != 'pending_payment';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.greyBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.payment,
                  size: 12,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(width: 8),
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
                  color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isPaid
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                  ),
                ),
                child: Text(
                  isPaid ? 'Paid' : 'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    color: isPaid ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isPaid ? 'Paid on $date' : 'Created on $date',
            style: const TextStyle(fontSize: 10, color: AppTheme.greyText),
          ),
          const SizedBox(height: 24),
          const Text(
            'Amount',
            style: TextStyle(fontSize: 12, color: AppTheme.greyText),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${widget.order.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final itemCount = widget.order.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final subtotal = widget.order.subtotal;
    final shipping = widget.order.shippingFee;
    final discount = widget.order.discount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal ($itemCount items)',
                style: const TextStyle(fontSize: 11, color: AppTheme.greyText),
              ),
              Text(
                '₹${subtotal.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: AppTheme.black),
              ),
            ],
          ),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Coupon Discount (SAVE20)',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
                Text(
                  '-₹${discount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Shipping Fee',
                style: TextStyle(fontSize: 11, color: AppTheme.greyText),
              ),
              Text(
                '₹${shipping.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 11, color: AppTheme.black),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
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
            style: TextStyle(fontSize: 9, color: AppTheme.greyText),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: AppTheme.greyBorder.withValues(alpha: 0.3)),
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
            const Icon(
              PhosphorIcons.caretRight,
              color: AppTheme.greyText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
