import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/checkout/screens/order_success_screen.dart';

enum PaymentState { initial, processing }

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  PaymentState _currentState = PaymentState.initial;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _showRazorpayModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRazorpayModal(),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 150),
            child: _currentState == PaymentState.initial ? _buildInitialState() : _buildProcessingState(),
          ),
          if (_currentState == PaymentState.initial)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(),
            )
          else
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: _buildWarningFooter(),
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment', style: TextStyle(color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.bold)),
          Row(
            children: const [
              Icon(Icons.lock_outline, size: 12, color: AppTheme.greyText),
              SizedBox(width: 4),
              Text('Secure Payment', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
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
                Icon(Icons.flash_on, size: 16, color: AppTheme.black), // Mock Razorpay logo
                Text('Razorpay', style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 16, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.change_circle_outlined, color: AppTheme.greyText),
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
            border: Border.all(color: AppTheme.greyBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Amount to Pay', style: TextStyle(color: AppTheme.greyText, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('â‚¹7,405', style: TextStyle(color: AppTheme.black, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text('View order details', style: TextStyle(color: AppTheme.black, fontSize: 12)),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.black),
                    ],
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
                    const Icon(Icons.shield_outlined, size: 80, color: AppTheme.greyBorder),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          children: const [
                            Icon(Icons.credit_card, size: 12, color: AppTheme.white),
                            SizedBox(width: 4),
                            Icon(Icons.circle, size: 4, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 20,
                      child: Icon(Icons.lock, size: 24, color: AppTheme.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text('Choose a payment method', style: TextStyle(color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        // Methods List
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.greyBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildPaymentMethodTile(Icons.flash_on, 'UPI', 'Google Pay, PhonePe, Paytm & more', onTap: _showRazorpayModal),
              const Divider(color: AppTheme.greyBorder, height: 1),
              _buildPaymentMethodTile(Icons.credit_card, 'Cards', 'Visa, Mastercard, RuPay & more'),
              const Divider(color: AppTheme.greyBorder, height: 1),
              _buildPaymentMethodTile(Icons.account_balance, 'Netbanking', 'All major banks supported'),
              const Divider(color: AppTheme.greyBorder, height: 1),
              _buildPaymentMethodTile(Icons.account_balance_wallet_outlined, 'Wallet', 'Paytm, Mobikwik & more'),
              const Divider(color: AppTheme.greyBorder, height: 1),
              _buildPaymentMethodTile(Icons.percent, 'EMI', 'Easy EMI options available'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Secure Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.greyBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: AppTheme.black),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('100% Secure Payments', style: TextStyle(color: AppTheme.black, fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                    Text('Your payment information is safe with us', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.greyText),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.black),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.black, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.greyText),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: const BoxDecoration(
        color: AppTheme.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderSuccessScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 20),
                  const SizedBox(width: 8),
                  const Text('Pay Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Text('â‚¹7,405', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shield_outlined, size: 14, color: AppTheme.greyText),
              SizedBox(width: 6),
              Text('Secured by Razorpay', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
            ],
          ),
        ],
      ),
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
                      Text('Razorpay', style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.w900, fontSize: 20, fontStyle: FontStyle.italic)),
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
                      Text('Gadget Store', style: TextStyle(color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Order #GS1234567890', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                    ],
                  ),
                  Row(
                    children: const [
                      Text('â‚¹7,405', style: TextStyle(color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      Icon(Icons.keyboard_arrow_down, size: 20, color: AppTheme.black),
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
                    child: Container(
                      height: 1,
                      color: AppTheme.greyBorder,
                    ),
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
                      Text('Pay using UPI', style: TextStyle(color: AppTheme.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Scan any UPI QR with your preferred app', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.greyBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: AppTheme.black, size: 20),
                  ),
                ],
              ),
            ),
            // UPI Apps list
            _buildUpiAppTile('Google Pay', Colors.blue, 'G'),
            _buildUpiAppTile('PhonePe', Colors.deepPurple, 'P'),
            _buildUpiAppTile('Paytm', Colors.lightBlue, 'pay'),
            _buildUpiAppTile('BHIM', Colors.orange, 'B'),
            _buildUpiAppTile('Other UPI Apps', AppTheme.greyBorder, '...', iconColor: AppTheme.black),
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
                      Icon(Icons.shield_outlined, size: 14, color: AppTheme.greyText),
                      SizedBox(width: 6),
                      Text('Secure payments powered by Razorpay', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Text('PCI DSS', style: TextStyle(color: AppTheme.black, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text('VISA', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                      Icon(Icons.circle, color: Colors.orange, size: 16), // Mastercard mockup
                      Text('RuPay', style: TextStyle(color: Colors.indigo, fontSize: 12, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
                      Text('UPI', style: TextStyle(color: AppTheme.black, fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
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
        border: isSelected ? const Border(bottom: BorderSide(color: AppTheme.black, width: 2)) : null,
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

  Widget _buildUpiAppTile(String name, Color color, String initial, {Color iconColor = AppTheme.white}) {
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
              child: Text(initial, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(name, style: const TextStyle(color: AppTheme.black, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.greyText),
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
                      border: Border.all(color: Colors.green.withOpacity(0.2), width: 2),
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
                  child: const Icon(Icons.lock, size: 16, color: AppTheme.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),
        const Text('Confirming payment...', style: TextStyle(color: AppTheme.black, fontSize: 20, fontWeight: FontWeight.bold)),
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

  Widget _buildStepperItem({required bool isCompleted, required bool isActive, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          child: Column(
            children: [
              if (isCompleted)
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 24)
              else if (isActive)
                RotationTransition(
                  turns: _animationController,
                  child: const Icon(Icons.sync, color: Colors.green, size: 24),
                )
              else
                const Icon(Icons.radio_button_unchecked, color: AppTheme.greyBorder, size: 24),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: AppTheme.black, fontSize: 14, fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.greyText, fontSize: 12, height: 1.4)),
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
        color: isCompleted ? Colors.green.withOpacity(0.3) : AppTheme.greyBorder.withOpacity(0.5),
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
                Text('Do not press back or close the app', style: TextStyle(color: AppTheme.black, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('This may cause payment failure.', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
