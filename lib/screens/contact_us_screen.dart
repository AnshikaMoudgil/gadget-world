import 'package:flutter/material.dart';
import '../core/theme.dart';

enum ContactState { form, submitting, success }

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  ContactState _currentState = ContactState.form;
  bool _hasMessageError = false;

  final TextEditingController _nameController = TextEditingController(text: 'Rohit Sharma');
  final TextEditingController _emailController = TextEditingController(text: 'rohit.sharma@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '+91 98765 43210');
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {}); // Rebuild to update character count
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Basic validation for mockup purposes: if empty or 'error', show error
    if (_messageController.text.trim().isEmpty || _messageController.text.toLowerCase() == 'error') {
      setState(() {
        _hasMessageError = true;
      });
      return;
    }

    setState(() {
      _hasMessageError = false;
      _currentState = ContactState.submitting;
    });

    // Simulate network request
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentState = ContactState.success;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentState == ContactState.success ? _buildSuccessView() : _buildFormView(),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Contact Us', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text("We're here to help. Send us a message.", style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name'),
          _buildTextField(controller: _nameController, hint: 'Enter full name', icon: Icons.person_outline),
          const SizedBox(height: 16),
          _buildLabel('Email Address'),
          _buildTextField(controller: _emailController, hint: 'Enter email address', icon: Icons.email_outlined),
          const SizedBox(height: 16),
          _buildLabel('Phone Number'),
          _buildTextField(controller: _phoneController, hint: 'Enter phone number', icon: Icons.phone_outlined),
          const SizedBox(height: 16),
          _buildLabel('Message'),
          _buildMessageField(),
          if (_hasMessageError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.red, size: 16),
                  SizedBox(width: 4),
                  Text('Please enter a message.', style: TextStyle(color: Colors.red, fontSize: 12)),
                ],
              ),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _currentState == ContactState.submitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppTheme.black, // Keep it black even when disabled for loading state
              ),
              child: _currentState == ContactState.submitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Text('Submitting...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.white)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            SizedBox(width: 16),
                            Icon(Icons.send_outlined, size: 20, color: AppTheme.white),
                            SizedBox(width: 8),
                            Text('Submit Inquiry', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.white)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.arrow_forward, size: 20, color: AppTheme.white),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSupportInfoCard(),
          const SizedBox(height: 48), // Scroll padding
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.greyBorder),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: AppTheme.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppTheme.greyText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: Icon(icon, color: AppTheme.black, size: 20),
        ),
      ),
    );
  }

  Widget _buildMessageField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _hasMessageError ? Colors.red : AppTheme.greyBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _messageController,
            maxLines: 5,
            maxLength: 500,
            style: const TextStyle(fontSize: 14, color: AppTheme.black),
            decoration: const InputDecoration(
              hintText: 'I want to know more about bulk orders and corporate discounts.',
              hintStyle: TextStyle(fontSize: 14, color: AppTheme.greyText),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterText: '', // We use a custom counter
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
            child: Text(
              '${_messageController.text.length}/500',
              style: const TextStyle(fontSize: 10, color: AppTheme.greyText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greyBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppTheme.white, shape: BoxShape.circle),
            child: const Icon(Icons.support_agent_outlined, color: AppTheme.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('You can also reach us at', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
                SizedBox(height: 2),
                Text('support@example.com', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black)),
                SizedBox(height: 2),
                Text('Mon - Sat, 10:00 AM - 6:00 PM', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          ),
          const SizedBox(height: 24),
          const Text('Thank You!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.black)),
          const SizedBox(height: 12),
          const Text(
            'Your message has been sent successfully.\nWe\'ll get back to you soon.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.greyText, height: 1.4),
          ),
          const SizedBox(height: 32),
          // Ticket ID Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.greyBorder, style: BorderStyle.solid), // Flutter doesn't have dashed border built-in without packages, using solid
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Ticket ID', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
                    const SizedBox(height: 4),
                    Text('#TKT-250709', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade600)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.greyBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.copy_outlined, size: 20, color: AppTheme.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'You will also receive a confirmation email\nshortly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to home/dashboard
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Back to Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _messageController.clear();
                  _currentState = ContactState.form;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.black,
                side: const BorderSide(color: AppTheme.greyBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.email_outlined, size: 20),
              label: const Text('Email Us Again', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
          _buildSupportInfoCard(),
        ],
      ),
    );
  }
}
