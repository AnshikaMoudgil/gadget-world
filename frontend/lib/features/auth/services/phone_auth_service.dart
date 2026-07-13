import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> sendOTP(String phone) async {
    await _supabase.auth.signInWithOtp(
      phone: phone,
    );
  }

  Future<AuthResponse> verifyOTP(String phone, String token) async {
    return await _supabase.auth.verifyOTP(
      type: OtpType.sms,
      token: token,
      phone: phone,
    );
  }
}
