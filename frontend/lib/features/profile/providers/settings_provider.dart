import 'package:flutter/foundation.dart';
import 'package:gadget_world/features/profile/models/user_settings.dart';
import 'package:gadget_world/features/profile/services/settings_api_service.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsApiService _apiService = SettingsApiService();

  UserSettings? _settings;
  bool _isLoading = false;
  String? _error;

  UserSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSettings(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _apiService.getSettings(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(String token, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await _apiService.updateSettings(token, data);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _settings = null;
    _error = null;
    notifyListeners();
  }
}
