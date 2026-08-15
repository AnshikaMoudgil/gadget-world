import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/features/more/providers/support_provider.dart';
import 'package:gadget_world/features/more/screens/ticket_chat_screen.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

enum ContactState { form, submitting, success }

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  ContactState _currentState = ContactState.form;
  bool _hasMessageError = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_messageController.text.trim().isEmpty) {
      setState(() => _hasMessageError = true);
      return;
    }

    setState(() {
      _hasMessageError = false;
      _currentState = ContactState.submitting;
    });

    final provider = Provider.of<SupportProvider>(context, listen: false);
    
    final messagePayload = '''
Name: ${_nameController.text.trim()}
Email: ${_emailController.text.trim()}
Phone: ${_phoneController.text.trim()}

Message:
${_messageController.text.trim()}
''';

    final success = await provider.createTicket(
      subject: 'Contact Us Inquiry',
      category: 'other',
      message: messagePayload,
    );

    if (mounted) {
      if (success) {
        setState(() {
          _currentState = ContactState.success;
        });
      } else {
        setState(() {
          _currentState = ContactState.form;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? 'Failed to create ticket')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.black),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Support',
              style: TextStyle(
                color: AppTheme.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "We're here to help",
              style: TextStyle(color: AppTheme.greyText, fontSize: 12),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.black,
          unselectedLabelColor: AppTheme.greyText,
          indicatorColor: AppTheme.black,
          tabs: const [
            Tab(text: 'My Tickets'),
            Tab(text: 'New Ticket'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildMyTicketsView(), _buildFormArea()],
      ),
    );
  }

  Widget _buildFormArea() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _currentState == ContactState.success
          ? _buildSuccessView()
          : _buildFormView(),
    );
  }

  Widget _buildMyTicketsView() {
    return Consumer<SupportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tickets = provider.tickets;

        if (tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.support_agent,
                  size: 64,
                  color: AppTheme.greyText,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No tickets yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create a new ticket if you need help',
                  style: TextStyle(color: AppTheme.greyText),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.black,
                    foregroundColor: AppTheme.white,
                  ),
                  child: const Text('Create Ticket'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: tickets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketChatScreen(ticket: ticket),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.greyBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ticket.ticketNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                ticket.status == 'open' ||
                                    ticket.status == 'in_progress'
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ticket.status.toUpperCase(),
                            style: TextStyle(
                              color:
                                  ticket.status == 'open' ||
                                      ticket.status == 'in_progress'
                                  ? Colors.orange.shade800
                                  : Colors.green.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ticket.subject,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ticket.category.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.greyText,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(ticket.createdAt.toLocal()),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.greyText,
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
      },
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Full Name'),
          _buildTextField(
            controller: _nameController,
            hint: 'Rohit Sharma',
            icon: PhosphorIcons.user,
          ),
          const SizedBox(height: 16),
          _buildLabel('Email Address'),
          _buildTextField(
            controller: _emailController,
            hint: 'rohit.sharma@example.com',
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 16),
          _buildLabel('Phone Number'),
          _buildTextField(
            controller: _phoneController,
            hint: '+91 98765 43210',
            icon: Icons.phone_outlined,
          ),
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
                  Text(
                    'Please enter a message.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _currentState == ContactState.submitting
                  ? null
                  : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppTheme.black,
              ),
              child: _currentState == ContactState.submitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: Text(
                            'Submitting...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.white,
                            ),
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
                            Icon(
                              Icons.send_outlined,
                              size: 20,
                              color: AppTheme.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Submit Ticket',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.white,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(
                            PhosphorIcons.arrowRight,
                            size: 20,
                            color: AppTheme.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSupportInfoCard(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool hasError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hasError ? Colors.red : AppTheme.greyBorder),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: AppTheme.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppTheme.greyText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
        border: Border.all(
          color: _hasMessageError ? Colors.red : AppTheme.greyBorder,
        ),
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
              hintText: 'Describe your issue in detail...',
              hintStyle: TextStyle(fontSize: 14, color: AppTheme.greyText),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterText: '',
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
        color: AppTheme.greyBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              color: AppTheme.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'You can also reach us at',
                  style: TextStyle(fontSize: 10, color: AppTheme.greyText),
                ),
                SizedBox(height: 2),
                Text(
                  'support@example.com',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mon - Sat, 10:00 AM - 6:00 PM',
                  style: TextStyle(fontSize: 10, color: AppTheme.greyText),
                ),
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
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Thank You!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your message has been sent successfully.\nWe\'ll get back to you soon.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.greyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          // Ticket ID Box
          Consumer<SupportProvider>(
            builder: (context, provider, child) {
              final ticketId = provider.tickets.isNotEmpty ? provider.tickets.first.ticketNumber : '#TKT-UNKNOWN';
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  // Dotted border equivalent using Container for simplicity
                  border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5, style: BorderStyle.solid),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Ticket ID', style: TextStyle(fontSize: 10, color: AppTheme.greyText)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ticketId,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const Icon(Icons.copy_outlined, color: AppTheme.black, size: 16),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'You will also receive a confirmation email\nshortly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.greyText,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Back to Home',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(PhosphorIcons.arrowRight, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _nameController.clear();
                  _emailController.clear();
                  _phoneController.clear();
                  _messageController.clear();
                  _currentState = ContactState.form;
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.black,
                side: const BorderSide(color: AppTheme.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.mail_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Email Us Again',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildSupportInfoCard(),
        ],
      ),
    );
  }
}
