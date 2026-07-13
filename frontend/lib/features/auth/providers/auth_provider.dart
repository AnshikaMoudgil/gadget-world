import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/models/profile_model.dart';
import '../../profile/services/profile_service.dart';
import '../services/auth_service.dart';
import '../services/google_auth_service.dart';
import '../services/phone_auth_service.dart';
import '../services/session_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  final SessionService _sessionService = SessionService();
  final ProfileService _profileService = ProfileService();

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

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _authService.signInWithEmail(email: email, password: password);
      
      // Validate if user has a profile
      if (res.user != null) {
        final profile = await _profileService.getProfile(res.user!.id);
        if (profile == null) {
          await _authService.signOut();
          throw const AuthException('No account exists with this email. Please sign up first.');
        }
      }
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

  Future<bool> signUpWithEmail(String email, String password, {required String fullName, required String mobileNumber}) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _authService.signUp(email: email, password: password);
      
      if (res.user != null) {
        await _profileService.createProfile(Profile(
          id: res.user!.id,
          fullName: fullName,
          email: email,
          phoneNumber: mobileNumber,
        ));
      }
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

  Future<bool> signInWithGoogle({bool isSignUp = false}) async {
    _setLoading(true);
    _setError(null);
    try {
      await _googleAuthService.signInWithGoogle(isSignUp: isSignUp);
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

  Future<bool> verifyOTP(String phone, String token, {bool isSignUp = false}) async {
    _setLoading(true);
    _setError(null);
    try {
      final res = await _phoneAuthService.verifyOTP(phone, token);
      
      final user = res.user;
      if (user != null) {
        final profile = await _profileService.getProfile(user.id);
        if (profile == null) {
          if (isSignUp) {
            await _profileService.createProfile(Profile(
              id: user.id,
              fullName: 'User',
              email: 'temp_${user.id}@example.com',
              phoneNumber: phone,
            ));
          } else {
            await _authService.signOut();
            throw const AuthException('No account exists with this phone number. Please sign up first.');
          }
        }
      }
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

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.resetPassword(email);
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
  
  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.updatePassword(newPassword);
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
