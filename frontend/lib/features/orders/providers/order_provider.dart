import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gadget_store/features/orders/models/order.dart';
import 'package:gadget_store/features/payments/services/payment_api_service.dart';

class OrderProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchOrders() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = _supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      final PaymentApiService apiService = PaymentApiService();
      final List<dynamic> data = await apiService.getOrders(token);

      _orders = data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearOrders() {
    _orders = [];
    _error = null;
    notifyListeners();
  }
}
