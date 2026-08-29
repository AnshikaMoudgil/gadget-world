import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/checkout/screens/order_success_screen.dart';
import 'package:gadget_store/features/checkout/screens/order_failed_screen.dart';
import 'package:razorpay_web/razorpay_web.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gadget_store/features/payments/services/payment_api_service.dart';
import 'package:gadget_store/features/orders/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/features/cart/providers/cart_provider.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';

enum PaymentState { initial, processing }

class PaymentScreen extends StatefulWidget {
  final String addressId;
  final double shippingFee;
  final double discount;
  const PaymentScreen({
    super.key,
    required this.addressId,
    required this.shippingFee,
    required this.discount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  PaymentState _currentState = PaymentState.initial;
  late AnimationController _animationController;
  late Razorpay _razorpay;
  final PaymentApiService _paymentApiService = PaymentApiService();
  bool _isProcessing = false;
  bool _showOrderDetails = false;
  int? _authoritativeAmountSubunits;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      // Capture cart data BEFORE verifyPayment clears it!
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final email = Supabase.instance.client.auth.currentUser?.email ?? '';
      final itemsCount = cartProvider.itemCount;

      final total = _authoritativeAmountSubunits != null
          ? _authoritativeAmountSubunits! / 100
          : cartProvider.total;
      final totalAmountStr = '₹${total.toStringAsFixed(0)}';

      final orderId = response.orderId ?? '';

      final itemsList =
          cartProvider.cart?.items.map((item) {
            String? firstImageUrl;
            if (item.product != null) {
              dynamic imagesData = item.product!['images'];
              if (imagesData is List && imagesData.isNotEmpty) {
                firstImageUrl = imagesData[0].toString();
              } else if (imagesData is String && imagesData.isNotEmpty) {
                final str = imagesData.trim();
                if (str.startsWith('{') && str.endsWith('}')) {
                  final inner = str.substring(1, str.length - 1);
                  if (inner.isNotEmpty) {
                    final parts = inner.split(',');
                    if (parts.isNotEmpty) {
                      firstImageUrl = parts[0].trim().replaceAll('"', '').replaceAll("'", "");
                    }
                  }
                } else if (str.startsWith('[') && str.endsWith(']')) {
                  try {
                    final parsed = jsonDecode(str);
                    if (parsed is List && parsed.isNotEmpty) {
                      firstImageUrl = parsed[0].toString();
                    }
                  } catch (_) {}
                } else {
                  firstImageUrl = str;
                }
              }
            }
            return {
              'title': item.product?['name']?.toString() ?? 'Product',
              'subtitle': 'Standard',
              'qty': item.quantity,
              'priceStr': '₹${item.product?['price']?.toString() ?? ''}',
              'imageUrl': firstImageUrl,
            };
          }).toList() ??
          [];

      await _paymentApiService.verifyPayment(
        token: token,
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
      );

      if (mounted) {
        Provider.of<OrderProvider>(context, listen: false).fetchOrders();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: orderId,
              email: email,
              totalAmountStr: totalAmountStr,
              itemsCount: itemsCount,
              items: itemsList,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderFailedScreen(
              errorMessage:
                  'Payment was deducted by Razorpay, but verification is pending. Please check your Orders page in a few minutes.\n\nError: $e',
            ),
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderFailedScreen(
          errorMessage: response.message ?? 'Unknown error',
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showErrorSnackbar('External Wallet selected: ${response.walletName}');
    setState(() => _isProcessing = false);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token == null) throw Exception('User not authenticated');

      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      final orderData = await _paymentApiService.createOrder(
        token: token,
        addressId: widget.addressId,
        couponCode: cartProvider.appliedCouponCode,
      );

      if (orderData['alreadyPaid'] == true) {
        if (!mounted) return;
        await Provider.of<OrderProvider>(context, listen: false).fetchOrders();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 3)),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment confirmed. Your order is in Orders.'),
          ),
        );
        return;
      }

      final keyId = orderData['keyId'] as String? ?? '';
      final orderId = orderData['orderId'] as String? ?? '';
      final amount = orderData['amount'];
      if (amount is! num || amount <= 0) {
        throw Exception('Backend returned an invalid checkout amount');
      }
      _authoritativeAmountSubunits = amount.toInt();

      var options = {
        'key': keyId,
        'amount': _authoritativeAmountSubunits,
        'name': 'Gadget World',
        'order_id': orderId,
        'description': 'Purchase from Gadget World',
        'retry': {'enabled': true, 'max_count': 1},
        'prefill': {
          'email': Supabase.instance.client.auth.currentUser?.email ?? '',
          'contact':
              '9999999999', // Required by Razorpay Web to prevent silent failure
        },
      };

      if (!mounted) return;
      _razorpay.open(options, context: context);

      // Also set a 15 second timeout to reset the button if Razorpay fails to open
      Future.delayed(const Duration(seconds: 15), () {
        if (mounted && _isProcessing) {
          setState(() => _isProcessing = false);
          _showErrorSnackbar(
            'Razorpay UI did not load. Check your internet connection or adblocker.',
          );
        }
      });
    } catch (e) {
      _showErrorSnackbar(e.toString());
      setState(() => _isProcessing = false);
    }
  }

  void _cycleState() {
    setState(() {
      if (_currentState == PaymentState.initial) {
        _currentState = PaymentState.processing;
      } else {
        _currentState = PaymentState.initial;
      }
    });
  }

  // ignore: unused_element
  void _showRazorpayModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRazorpayModal(),
    );
  }

  String _getTotalAmountStr() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final total = cartProvider.total;

    final formatCurrency = NumberFormat.simpleCurrency(
      name: 'INR',
      decimalDigits: 0,
    );
    return formatCurrency.format(total);
  }

  Widget _buildOrderDetailsBox() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var item in cartProvider.cart?.items ?? [])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${item.quantity}x ${item.product?['name'] ?? 'Product'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹${(item.product?['price'] ?? 0) * item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Shipping',
              style: TextStyle(fontSize: 12, color: AppTheme.greyText),
            ),
            Text(
              '₹${widget.shippingFee.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
          ],
        ),
        if (widget.discount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discount',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
                Text(
                  '-₹${widget.discount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 100),
            child: _currentState == PaymentState.initial
                ? _buildInitialState()
                : _buildProcessingState(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: _currentState == PaymentState.initial
                ? _buildFooter()
                : _buildWarningFooter(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment',
            style: TextStyle(
              color: AppTheme.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.lock_outline, size: 12, color: AppTheme.greyText),
              SizedBox(width: 4),
              Text(
                'Secure Payment',
                style: TextStyle(color: AppTheme.greyText, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: const [
                Icon(Icons.change_history, size: 16, color: AppTheme.black),
                Text(
                  'Razorpay',
                  style: TextStyle(
                    color: AppTheme.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.change_circle_outlined,
            color: AppTheme.greyText,
          ),
          onPressed: _cycleState,
          tooltip: 'Toggle UI State',
        ),
      ],
    );
  }

  Widget _buildInitialState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(
              color: AppTheme.greyBorder.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount to Pay',
                        style: TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTotalAmountStr(),
                        style: const TextStyle(
                          color: AppTheme.black,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOrderDetails = !_showOrderDetails;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'View order details',
                                style: TextStyle(
                                  color: AppTheme.black,
                                  fontSize: 12,
                                ),
                              ),
                              Icon(
                                _showOrderDetails
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 16,
                                color: AppTheme.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Graphic
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.shield,
                          size: 80,
                          color: Color(0xFFF0F0F0),
                        ),
                        const Positioned(
                          top: 15,
                          child: Icon(
                            Icons.lock,
                            size: 28,
                            color: AppTheme.black,
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 0,
                          child: Stack(
                            children: [
                              Transform.translate(
                                offset: const Offset(8, -8),
                                child: Container(
                                  width: 40,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Container(
                                width: 45,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppTheme.black,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                          width: 12,
                                          height: 2,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 20,
                                      height: 2,
                                      color: Colors.grey,
                                    ),
                                  ],
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
              if (_showOrderDetails) ...[
                const SizedBox(height: 16),
                const Divider(color: AppTheme.greyBorder),
                const SizedBox(height: 8),
                _buildOrderDetailsBox(),
              ],
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Pay with Razorpay Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pay with Razorpay',
                  style: TextStyle(
                    color: AppTheme.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: AppTheme.greyText,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '100% Secure Payments',
                      style: TextStyle(color: AppTheme.greyText, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: const [
                Icon(Icons.change_history, size: 16, color: Color(0xFF0C2444)),
                SizedBox(width: 2),
                Text(
                  'Razorpay',
                  style: TextStyle(
                    color: Color(0xFF0C2444),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Pay Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Pay ${_getTotalAmountStr()}',
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Center(
          child: Text(
            'You will be redirected to Razorpay to complete your payment securely.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.greyText, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.shield_outlined, size: 14, color: AppTheme.greyText),
        SizedBox(width: 6),
        Text(
          'Secured by Razorpay',
          style: TextStyle(color: AppTheme.greyText, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRazorpayModal() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.flash_on, size: 20, color: AppTheme.black),
                      Text(
                        'Razorpay',
                        style: TextStyle(
                          color: AppTheme.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: AppTheme.black),
                  ),
                ],
              ),
            ),
            // Order details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Gadget World',
                        style: TextStyle(
                          color: AppTheme.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Order #GS1234567890',
                        style: TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _getTotalAmountStr(),
                        style: const TextStyle(
                          color: AppTheme.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppTheme.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(height: 1, color: AppTheme.greyBorder),
                  ),
                  Row(
                    children: [
                      _buildTab('UPI', true),
                      _buildTab('Cards', false),
                      _buildTab('Netbanking', false),
                      _buildTab('Wallet', false),
                      _buildTab('EMI', false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // UPI Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pay using UPI',
                        style: TextStyle(
                          color: AppTheme.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Scan any UPI QR with your preferred app',
                        style: TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.greyBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: AppTheme.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // UPI Apps list
            _buildUpiAppTile('Google Pay', Colors.blue, 'G'),
            _buildUpiAppTile('PhonePe', Colors.deepPurple, 'P'),
            _buildUpiAppTile('Paytm', Colors.lightBlue, 'pay'),
            _buildUpiAppTile('BHIM', Colors.orange, 'B'),
            _buildUpiAppTile(
              'Other UPI Apps',
              AppTheme.greyBorder,
              '...',
              iconColor: AppTheme.black,
            ),
            const SizedBox(height: 24),
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              color: AppTheme.greyBackground,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppTheme.greyText,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Secure payments powered by Razorpay',
                        style: TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text(
                        'PCI DSS',
                        style: TextStyle(
                          color: AppTheme.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'VISA',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Icon(
                        Icons.circle,
                        color: Colors.orange,
                        size: 16,
                      ), // Mastercard mockup
                      Text(
                        'RuPay',
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'UPI',
                        style: TextStyle(
                          color: AppTheme.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12, right: 24),
      decoration: BoxDecoration(
        border: isSelected
            ? const Border(bottom: BorderSide(color: AppTheme.black, width: 2))
            : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.black : AppTheme.greyText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildUpiAppTile(
    String name,
    Color color,
    String initial, {
    Color iconColor = AppTheme.white,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close modal
        setState(() {
          _currentState = PaymentState.processing;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: AppTheme.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(PhosphorIcons.caretRight, color: AppTheme.greyText),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingState() {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Graphic
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing circle
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
              const Positioned(
                top: 0,
                child: Icon(Icons.circle, size: 8, color: Colors.green),
              ),
              // Inner graphics
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.credit_card, size: 24, color: AppTheme.white),
                  ],
                ),
              ),
              Positioned(
                bottom: 30,
                right: 30,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock,
                    size: 16,
                    color: AppTheme.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        const Text(
          'Confirming payment...',
          style: TextStyle(
            color: AppTheme.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'We are confirming your payment with the bank.\nThis usually takes a few seconds.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.greyText, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 48),
        // Stepper
        _buildStepperItem(
          isCompleted: true,
          isActive: false,
          title: 'Payment initiated',
          subtitle: 'Your payment has been securely sent to the bank.',
        ),
        _buildStepperLine(isCompleted: true),
        _buildStepperItem(
          isCompleted: false,
          isActive: true,
          title: 'Confirming payment',
          subtitle: 'Please do not close this screen.',
        ),
        _buildStepperLine(isCompleted: false),
        _buildStepperItem(
          isCompleted: false,
          isActive: false,
          title: 'Payment confirmation',
          subtitle: 'You will be redirected once the payment is confirmed.',
        ),
      ],
    );
  }

  Widget _buildStepperItem({
    required bool isCompleted,
    required bool isActive,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              if (isCompleted)
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 24,
                )
              else if (isActive)
                RotationTransition(
                  turns: _animationController,
                  child: const Icon(Icons.sync, color: Colors.green, size: 24),
                )
              else
                const Icon(
                  Icons.radio_button_unchecked,
                  color: AppTheme.greyBorder,
                  size: 24,
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 14,
                  fontWeight: isActive || isCompleted
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.greyText,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperLine({required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.only(left: 11, top: 4, bottom: 4),
      child: Container(
        width: 2,
        height: 32,
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.3)
            : AppTheme.greyBorder.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildWarningFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.black, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Do not press back or close the app',
                  style: TextStyle(
                    color: AppTheme.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'This may cause payment failure.',
                  style: TextStyle(color: AppTheme.greyText, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
