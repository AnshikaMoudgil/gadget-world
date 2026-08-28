import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/optimized_network_image.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum OrderSuccessState { collapsed, expanded, graphic }

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  final String email;
  final String totalAmountStr;
  final int itemsCount;
  final List<Map<String, dynamic>> items; // title, subtitle, qty, priceStr

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.email,
    required this.totalAmountStr,
    required this.itemsCount,
    required this.items,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  OrderSuccessState _currentState = OrderSuccessState.collapsed;

  void _cycleState() {
    setState(() {
      if (_currentState == OrderSuccessState.collapsed) {
        _currentState = OrderSuccessState.expanded;
      } else if (_currentState == OrderSuccessState.expanded) {
        _currentState = OrderSuccessState.graphic;
      } else {
        _currentState = OrderSuccessState.collapsed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Usually no back button on success screen
        actions: [
          IconButton(
            icon: const Icon(
              Icons.change_circle_outlined,
              color: AppTheme.greyText,
            ),
            onPressed: _cycleState,
            tooltip: 'Cycle View State',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildOrderNumberCard(),
                const SizedBox(height: 24),
                if (_currentState == OrderSuccessState.collapsed)
                  _buildCollapsedSummary()
                else if (_currentState == OrderSuccessState.expanded)
                  _buildExpandedSummary()
                else
                  _buildGraphicView(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 10,
                left: 20,
                child: Icon(
                  Icons.circle,
                  size: 6,
                  color: Colors.green.shade200,
                ),
              ),
              Positioned(
                top: 20,
                right: 30,
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.green.shade400,
                ),
              ),
              Positioned(
                bottom: 20,
                left: 10,
                child: Icon(Icons.circle, size: 4, color: AppTheme.greyBorder),
              ),
              Positioned(
                bottom: 30,
                right: 10,
                child: Icon(
                  Icons.circle,
                  size: 6,
                  color: Colors.green.shade300,
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                child: Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.green.shade100,
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppTheme.white, size: 40),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Order Placed Successfully!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Thank you for shopping with us.\nYour order has been placed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppTheme.greyText, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildOrderNumberCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Number',
                    style: TextStyle(fontSize: 12, color: AppTheme.greyText),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.orderId.isEmpty ? 'Processing...' : widget.orderId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy, color: AppTheme.black, size: 20),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(color: AppTheme.greyBorder, height: 1),
          ),
          RichText(
            text: TextSpan(
              text: 'A confirmation email has been sent to\n',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.greyText,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: widget.email,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.greyBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                PhosphorIcons.shoppingBag,
                'Items',
                '${widget.itemsCount} Items',
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppTheme.greyBorder, height: 1),
              ),
              _buildSummaryRow(
                Icons.currency_rupee,
                'Total Amount',
                widget.totalAmountStr,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(color: AppTheme.greyBorder, height: 1),
              ),
              _buildSummaryRow(
                Icons.calendar_today_outlined,
                'Placed On',
                DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDeliveryEstimateCard(),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.black),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.black),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
        ),
      ],
    );
  }

  Widget _buildExpandedSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            Text(
              '${widget.itemsCount} Items • ${widget.totalAmountStr}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...widget.items.map((item) {
          return Column(
            children: [
              _buildOrderItem(
                item['title'] ?? '',
                item['subtitle'] ?? '',
                item['qty'] ?? 1,
                item['priceStr'] ?? '',
                imageUrl: item['imageUrl'],
              ),
              const Divider(color: AppTheme.greyBorder, height: 1),
            ],
          );
        }),
        const SizedBox(height: 16),
        _buildDeliveryEstimateCard(),
      ],
    );
  }

  Widget _buildOrderItem(
    String title,
    String color,
    int qty,
    String price, {
    String? imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.greyBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? OptimizedNetworkImage(
                    imageUrl: imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorIcon: PhosphorIcons.shoppingBag,
                  )
                : const Icon(
                    PhosphorIcons.shoppingBag,
                    color: AppTheme.greyText,
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
                ),
                const SizedBox(height: 4),
                Text(
                  color,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $qty',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
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
    );
  }

  Widget _buildDeliveryEstimateCard() {
    final estimateDate = DateTime.now().add(const Duration(days: 4));
    final estimateDateStr = DateFormat('dd MMM yyyy').format(estimateDate);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
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
              children: [
                const Text(
                  'We\'ll notify you once your order is shipped.',
                  style: TextStyle(fontSize: 12, color: AppTheme.black),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    text: 'Estimated delivery: ',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyText,
                    ),
                    children: [
                      TextSpan(
                        text: estimateDateStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphicView() {
    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 20,
                left: 40,
                child: Icon(Icons.circle, size: 6, color: AppTheme.greyBorder),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Icon(Icons.circle, size: 4, color: AppTheme.greyBorder),
              ),
              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.greyBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.greyBorder),
                ),
                child: const Center(
                  child: Icon(
                    PhosphorIcons.shoppingBagFill,
                    size: 40,
                    color: AppTheme.black,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 50,
                child: Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.credit_card,
                      size: 20,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 35,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBadge(Icons.workspace_premium_outlined, 'Quality Assured'),
            _buildBadge(Icons.inventory_2_outlined, 'Easy Returns'),
            _buildBadge(Icons.headphones_outlined, 'Top Support'),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.greyBorder),
            ),
            child: Icon(icon, color: AppTheme.black, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: const BoxDecoration(color: AppTheme.white),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 3),
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
                  Text(
                    'View Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(PhosphorIcons.arrowRight, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 1),
                  ),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.black,
                side: const BorderSide(color: AppTheme.black, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
