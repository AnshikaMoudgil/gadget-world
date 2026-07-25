import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> fetchNotifications() async {
    if (_supabase.auth.currentUser == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .order('created_at', ascending: false);

      _notifications = (response as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList();

      _updateUnreadCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    if (_supabase.auth.currentUser == null) return;

    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      final old = _notifications[index];
      _notifications[index] = NotificationModel(
        id: old.id,
        userId: old.userId,
        title: old.title,
        body: old.body,
        type: old.type,
        referenceType: old.referenceType,
        referenceId: old.referenceId,
        imageUrl: old.imageUrl,
        isRead: true,
        readAt: DateTime.now(),
        createdAt: old.createdAt,
      );
      _updateUnreadCount();
      notifyListeners();

      try {
        await _supabase.rpc(
          'mark_notifications_read',
          params: {
            'p_notification_ids': [notificationId],
          },
        );
      } catch (e) {
        // Revert on failure
        _notifications[index] = old;
        _updateUnreadCount();
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (_supabase.auth.currentUser == null) return;
    if (_unreadCount == 0) return;

    // Optimistic update
    final oldNotifications = List<NotificationModel>.from(_notifications);
    _notifications = _notifications.map((n) {
      if (!n.isRead) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          body: n.body,
          type: n.type,
          referenceType: n.referenceType,
          referenceId: n.referenceId,
          imageUrl: n.imageUrl,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: n.createdAt,
        );
      }
      return n;
    }).toList();
    _updateUnreadCount();
    notifyListeners();

    try {
      await _supabase.rpc('mark_all_notifications_read');
    } catch (e) {
      // Revert on failure
      _notifications = oldNotifications;
      _updateUnreadCount();
      notifyListeners();
    }
  }

  void clearNotificationsLocal() {
    _notifications = [];
    _unreadCount = 0;
    _error = null;
    notifyListeners();
  }
}
