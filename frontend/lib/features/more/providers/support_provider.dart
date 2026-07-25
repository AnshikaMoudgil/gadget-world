import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/support_ticket.dart';

class SupportProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  
  List<SupportTicket> _tickets = [];
  bool _isLoading = false;
  String? _error;

  List<SupportTicket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTickets() async {
    if (_supabase.auth.currentUser == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('support_tickets')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

      _tickets = (response as List)
          .map((item) => SupportTicket.fromJson(item))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTicket({
    required String subject,
    required String category,
    required String message,
    String? orderId,
  }) async {
    if (_supabase.auth.currentUser == null) return false;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create the ticket
      final ticketResponse = await _supabase.from('support_tickets').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'subject': subject,
        'category': category,
        if (orderId != null) 'order_id': orderId,
      }).select().single();

      final newTicket = SupportTicket.fromJson(ticketResponse);
      
      // Create the initial message
      await _supabase.from('support_messages').insert({
        'ticket_id': newTicket.id,
        'sender_id': _supabase.auth.currentUser!.id,
        'message': message,
      });

      _tickets.insert(0, newTicket);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<SupportMessage>> fetchMessages(String ticketId) async {
    try {
      final response = await _supabase
          .from('support_messages')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((item) => SupportMessage.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendMessage({
    required String ticketId,
    required String message,
  }) async {
    if (_supabase.auth.currentUser == null) return false;
    
    try {
      await _supabase.from('support_messages').insert({
        'ticket_id': ticketId,
        'sender_id': _supabase.auth.currentUser!.id,
        'message': message,
      });
      // The DB trigger updates the ticket's updated_at
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearTicketsLocal() {
    _tickets = [];
    _error = null;
    notifyListeners();
  }
}
