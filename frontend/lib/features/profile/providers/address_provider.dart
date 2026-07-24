import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gadget_store/features/profile/models/address.dart';
import 'package:gadget_store/features/profile/services/address_api_service.dart';

class AddressProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AddressApiService _apiService = AddressApiService();

  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Address? get defaultAddress {
    try {
      return _addresses.firstWhere((a) => a.isDefault);
    } catch (e) {
      if (_addresses.isNotEmpty) {
        return _addresses.first;
      }
      return null;
    }
  }

  Future<void> fetchAddresses() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _addresses = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = _supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      _addresses = await _apiService.getAddresses(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAddress(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = _supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      final newAddress = await _apiService.createAddress(token, data);

      // If it's the first address, or specifically set as default, handle it
      if (data['is_default'] == true || _addresses.isEmpty) {
        // Demote others locally if needed, though backend handles it
        for (var i = 0; i < _addresses.length; i++) {
          _addresses[i] = _addresses[i].copyWith(isDefault: false);
        }
      }

      _addresses.insert(0, newAddress);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress(
    String addressId,
    Map<String, dynamic> data,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = _supabase.auth.currentSession?.accessToken;
      if (token == null) throw Exception('No session token');

      final updated = await _apiService.updateAddress(token, addressId, data);

      final index = _addresses.indexWhere((a) => a.id == addressId);
      if (index != -1) {
        _addresses[index] = updated;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null) throw Exception('No session token');

    try {
      await _apiService.deleteAddress(token, addressId);
      _addresses.removeWhere((a) => a.id == addressId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null) throw Exception('No session token');

    try {
      await _apiService.setDefaultAddress(token, addressId);

      // Update local state to reflect the new default
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = _addresses[i].copyWith(
          isDefault: _addresses[i].id == addressId,
        );
      }

      // Sort so default is at the top
      _addresses.sort((a, b) {
        if (a.isDefault) return -1;
        if (b.isDefault) return 1;
        return (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        );
      });

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _addresses = [];
    _error = null;
    notifyListeners();
  }
}
