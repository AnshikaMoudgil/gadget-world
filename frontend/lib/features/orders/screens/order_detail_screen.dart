import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

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
                    const Text('Items (3)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.black)),
                    const SizedBox(height: 16),
                    _buildItemsList(),
                    const SizedBox(height: 24),
                    _buildDeliveryTimeline(),
                    const SizedBox(height: 24),
                    const Text('Shipping Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.black)),
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
                    _buildActionTile(Icons.download_outlined, 'Download Invoice'),
                    const SizedBox(height: 12),
                    _buildActionTile(Icons.local_shipping_outlined, 'Track Package'),
                    const SizedBox(height: 12),
                    _buildActionTile(Icons.assignment_return_outlined, 'Return or Replace'),
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
              child: const Text('Order Detail', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.headphones_outlined, color: AppTheme.black), onPressed: () {}),
              IconButton(icon: const Icon(Icons.more_vert, color: AppTheme.black), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Order #GS1234567890', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
              SizedBox(height: 4),
              Text('Placed on 09 Jul 2025, 10:41 AM', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
            child: const Text('Delivered', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: AppTheme.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivered on 11 Jul 2025, 04:45 PM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                const SizedBox(height: 4),
                const Text('Your order has been delivered successfully.', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Text('View proof of delivery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                    Icon(Icons.chevron_right, size: 16, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),
          // Mock Box Graphic
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.inventory_2, color: Colors.green.shade200, size: 40),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 12, color: AppTheme.white),
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
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildOrderItem('boAt Rockerz 450', 'Black', 1, 'â‚¹1,999', null, Icons.headphones),
          const Divider(color: AppTheme.greyBorder, height: 24),
          _buildOrderItem('Noise ColorFit Pulse 3', 'Jet Black', 2, 'â‚¹5,998', 'â‚¹2,999 each', Icons.watch),
          const Divider(color: AppTheme.greyBorder, height: 24),
          _buildOrderItem('Ambrane 10000mAh Power Bank', 'Black', 1, 'â‚¹1,199', null, Icons.battery_charging_full),
        ],
      ),
    );
  }

  Widget _buildOrderItem(String title, String subtitle, int qty, String price, String? unitPrice, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: AppTheme.greyBackground, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTheme.black),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
              const SizedBox(height: 4),
              Text('Qty: $qty', style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
            if (unitPrice != null) ...[
              const SizedBox(height: 4),
              Text(unitPrice, style: const TextStyle(fontSize: 10, color: AppTheme.greyText)),
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
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
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
                    decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.local_shipping_outlined, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Delivery Timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                        SizedBox(height: 4),
                        Text('Delivered on 11 Jul 2025, 04:45 PM', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                      ],
                    ),
                  ),
                  Icon(_isTimelineExpanded ? Icons.expand_less : Icons.expand_more, color: AppTheme.black),
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
                  _buildTimelineItem('Order Placed', '09 Jul 2025, 10:41 AM', true, false),
                  _buildTimelineItem('Order Confirmed', '09 Jul 2025, 11:30 AM', true, false),
                  _buildTimelineItem('Packed', '10 Jul 2025, 09:15 AM', true, false),
                  _buildTimelineItem(
                    'Shipped', 
                    'AWB: 1234567890\nCourier: Delhivery', 
                    true, 
                    false,
                    trailingDate: '10 Jul 2025, 07:40 PM',
                  ),
                  _buildTimelineItem('Reached Delhi Hub', '11 Jul 2025, 06:40 AM', true, false),
                  _buildTimelineItem('Out for Delivery', '11 Jul 2025, 09:15 AM', true, false),
                  _buildTimelineItem('Delivered', '11 Jul 2025, 04:45 PM', true, true, isLast: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted, bool isActive, {bool isLast = false, String? trailingDate}) {
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
                border: Border.all(color: isCompleted ? Colors.green : AppTheme.greyBorder, width: 2),
                shape: BoxShape.circle,
              ),
              child: isActive ? const Center(child: Icon(Icons.check, size: 10, color: AppTheme.white)) : null,
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
            padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0), // Spacing for next item
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isCompleted ? AppTheme.black : AppTheme.greyText)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4)),
                    ],
                  ),
                ),
                if (trailingDate != null)
                  Text(trailingDate, style: const TextStyle(fontSize: 10, color: AppTheme.greyText)),
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
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
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
                    const Text('Rohit Sharma', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                      child: const Text('Default', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                    const Spacer(),
                    const Text('Change', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('456, Lajpat Nagar, Part 2,\nNear Metro Station, New Delhi - 110024', style: TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4)),
                const SizedBox(height: 8),
                const Text('+91 98765 43210', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.flash_on, size: 14, color: AppTheme.black),
              const SizedBox(width: 4),
              const Expanded(child: Text('Razorpay (UPI)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                child: const Text('Paid', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Paid on 09 Jul 2025, 11:32 AM', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
          const SizedBox(height: 16),
          const Text('Amount', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
          const SizedBox(height: 4),
          const Text('â‚¹7,405', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.black)),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Subtotal (3 items)', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
              Text('â‚¹9,196', style: TextStyle(fontSize: 10, color: AppTheme.black)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Coupon Discount (SAVE20)', style: TextStyle(fontSize: 10, color: Colors.green)),
              Text('-â‚¹1,840', style: TextStyle(fontSize: 10, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Shipping Fee', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
              Text('â‚¹49', style: TextStyle(fontSize: 10, color: AppTheme.black)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(color: AppTheme.greyBorder, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Total Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black)),
              Text('â‚¹7,405', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('(Inclusive of all taxes)', style: TextStyle(fontSize: 8, color: AppTheme.greyText)),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.black, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black))),
          const Icon(Icons.chevron_right, color: AppTheme.greyText, size: 20),
        ],
      ),
    );
  }
}
