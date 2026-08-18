import 'dart:async';
import '../../../core/database/supabase_db.dart';
import 'notification_service.dart';

class NotificationCronService {
  final NotificationService _notificationService = NotificationService();
  Timer? _timer;

  /// Starts the background cron jobs
  void start() {
    // Run the checks immediately, then periodically (e.g., every 6 hours)
    // For testing/development, you might want to change this to a shorter duration.
    _runChecks();
    _timer = Timer.periodic(const Duration(hours: 6), (timer) {
      _runChecks();
    });
    print('Notification cron service started.');
  }

  void stop() {
    _timer?.cancel();
  }

  Future<void> _runChecks() async {
    try {
      print('[Cron] Running notification checks...');
      await _checkAbandonedCarts();
      await _checkPendingPayments();
    } catch (e) {
      print('[Cron] Error running checks: $e');
    }
  }

  Future<void> _checkAbandonedCarts() async {
    // Find carts that were last updated more than 3 days ago
    final threeDaysAgo = DateTime.now()
        .subtract(const Duration(days: 3))
        .toUtc()
        .toIso8601String();

    final carts = await SupabaseDb.client
        .from('carts')
        .select('id, user_id, updated_at, cart_items(id)')
        .lt('updated_at', threeDaysAgo);

    for (final cart in carts) {
      final items = cart['cart_items'] as List<dynamic>;
      if (items.isNotEmpty) {
        // Send a reminder
        await _notificationService.notifyUser(
          userId: cart['user_id'],
          title: 'You left something behind!',
          body:
              'Your cart misses you. Complete your purchase before items run out of stock.',
          type: 'promotion',
        );

        // To prevent spamming, we could update the cart's updated_at or keep track of sent reminders.
        // Here we just "touch" the cart to bump its updated_at so it doesn't trigger again for 3 days.
        await SupabaseDb.client.from('carts').update({
          'updated_at': DateTime.now().toUtc().toIso8601String()
        }).eq('id', cart['id']);
      }
    }
  }

  Future<void> _checkPendingPayments() async {
    // Find orders pending payment older than 1 day
    final oneDayAgo = DateTime.now()
        .subtract(const Duration(days: 1))
        .toUtc()
        .toIso8601String();

    final orders = await SupabaseDb.client
        .from('orders')
        .select('id, user_id, order_number, created_at')
        .eq('status', 'pending_payment')
        .lt('created_at', oneDayAgo);

    for (final order in orders) {
      await _notificationService.notifyUser(
        userId: order['user_id'],
        title: 'Pending Payment Reminder',
        body:
            'Your order ${order['order_number']} is awaiting payment. Complete it soon!',
        type: 'payment',
        referenceType: 'order',
        referenceId: order['id'],
      );

      // Optionally, you might want to add a flag or table for "reminders sent" to avoid duplicate emails.
      // For simplicity, we just touch the updated_at or handle it gracefully.
      // We can update a note or similar to mark it reminded.
      await SupabaseDb.client
          .from('orders')
          .update({'updated_at': DateTime.now().toUtc().toIso8601String()}).eq(
              'id', order['id']);
    }
  }
}
