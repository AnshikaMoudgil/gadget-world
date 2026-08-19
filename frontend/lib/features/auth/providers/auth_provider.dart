import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/phone_auth_service.dart';
import '../services/session_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final SessionService _sessionService = SessionService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _authService.currentUser;
  bool get isAuthenticated => _sessionService.hasSession;

  AuthProvider() {
    _authService.onAuthStateChange.listen((data) {
      notifyListeners();
    });
    GoogleAuthService.authErrorStream.stream.listen((error) {
      _setError(error);
    });
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      await _googleAuthService.signInWithGoogle();
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Google sign in canceled or failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendOTP(String phone) async {
    _setLoading(true);
    _setError(null);
    try {
      await _phoneAuthService.sendOTP(phone);
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOTP(String phone, String token) async {
    _setLoading(true);
    _setError(null);
    try {
      await _phoneAuthService.verifyOTP(phone, token);
      // Profile row is auto-created by the DB trigger (handle_new_user_signup) for new users.
      // For existing users, login just succeeds.
      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } finally {
      _setLoading(false);
    }
  }
}
