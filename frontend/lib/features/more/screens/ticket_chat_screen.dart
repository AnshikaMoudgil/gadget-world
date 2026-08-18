import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/features/more/providers/support_provider.dart';
import 'package:gadget_world/features/more/models/support_ticket.dart';
import 'package:intl/intl.dart';

class TicketChatScreen extends StatefulWidget {
  final SupportTicket ticket;

  const TicketChatScreen({super.key, required this.ticket});

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<SupportMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final provider = Provider.of<SupportProvider>(context, listen: false);
    final messages = await provider.fetchMessages(widget.ticket.id);
    if (mounted) {
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    final tempId = DateTime.now().toString();

    // Optimistic UI update
    final newMessage = SupportMessage(
      id: tempId, // temp ID
      ticketId: widget.ticket.id,
      senderId: 'me', // doesn't matter for UI comparison if we just check role
      senderRole: 'customer',
      message: text,
      isInternal: false,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(newMessage);
    });
    _scrollToBottom();

    final provider = Provider.of<SupportProvider>(context, listen: false);
    final sentMessage = await provider.sendMessage(
      ticketId: widget.ticket.id,
      message: text,
    );

    if (sentMessage == null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to send message')));
      // Remove optimistic message
      setState(() {
        _messages.removeWhere((msg) => msg.id == tempId);
      });
    } else if (sentMessage != null && mounted) {
      setState(() {
        final index = _messages.indexWhere((msg) => msg.id == tempId);
        if (index != -1) {
          _messages[index] = sentMessage;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.greyBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ticket.ticketNumber,
              style: const TextStyle(
                color: AppTheme.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.ticket.subject,
              style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppTheme.black),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  widget.ticket.status == 'open' ||
                      widget.ticket.status == 'in_progress'
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.ticket.status.toUpperCase(),
              style: TextStyle(
                color:
                    widget.ticket.status == 'open' ||
                        widget.ticket.status == 'in_progress'
                    ? Colors.orange.shade800
                    : Colors.green.shade800,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderRole == 'customer';
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          if (widget.ticket.status != 'resolved' &&
              widget.ticket.status != 'closed')
            _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.black : AppTheme.white,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomRight: isMe
                ? const Radius.circular(0)
                : const Radius.circular(12),
            bottomLeft: !isMe
                ? const Radius.circular(0)
                : const Radius.circular(12),
          ),
          border: isMe ? null : Border.all(color: AppTheme.greyBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? AppTheme.white : AppTheme.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('hh:mm a, MMM dd').format(message.createdAt.toLocal()),
              style: TextStyle(
                color: isMe ? Colors.grey.shade400 : AppTheme.greyText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(top: BorderSide(color: AppTheme.greyBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: AppTheme.greyText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.greyBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: AppTheme.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
