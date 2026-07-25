import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/widgets/custom_text_field.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/features/auth/providers/auth_provider.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';
import 'package:gadget_store/features/auth/widgets/google_button.dart';
import 'package:gadget_store/features/auth/widgets/loading_button.dart';
import 'package:gadget_store/features/auth/widgets/otp_input.dart';
import 'package:gadget_store/features/auth/services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final String _selectedCountryCode = '+91';

  bool _isOtpSent = false;
  String _currentOtp = '';
  String? _lastError;
  Timer? _otpCooldownTimer;
  int _otpCooldownSeconds = 0;
  StreamSubscription? _authSubscription;
  AuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _authProvider!.addListener(_onAuthChange);
    });

    _authSubscription = GoogleAuthService.authSuccessStream.stream.listen((_) {
      if (mounted) _onSuccess();
    });
  }

  void _onAuthChange() {
    if (!mounted) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.errorMessage != null && auth.errorMessage != _lastError) {
      _lastError = auth.errorMessage;
      _showError(auth.errorMessage!);
    }
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthChange);
    _phoneController.dispose();
    _otpCooldownTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  void _startOtpCooldown() {
    setState(() => _otpCooldownSeconds = 60);
    _otpCooldownTimer?.cancel();
    _otpCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_otpCooldownSeconds > 0) {
        setState(() => _otpCooldownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFE11D48),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _onSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  Future<void> _loginWithGoogle() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      _onSuccess();
    } else if (!success && auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
    }
  }

  Future<void> _sendOtp() async {
    final phoneDigits = _phoneController.text.trim();
    if (phoneDigits.isEmpty || phoneDigits.length < 10) {
      _showError('Please enter a valid 10-digit mobile number');
      return;
    }

    final fullPhoneNumber = '$_selectedCountryCode$phoneDigits';

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.sendOTP(fullPhoneNumber);
    if (success) {
      setState(() => _isOtpSent = true);
      _startOtpCooldown();
    } else if (auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
    }
  }

  Future<void> _verifyOtp() async {
    if (_currentOtp.length != 6) {
      _showError('Please enter the full 6-digit OTP');
      return;
    }
    final fullPhoneNumber =
        '$_selectedCountryCode${_phoneController.text.trim()}';

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyOTP(fullPhoneNumber, _currentOtp);
    if (success && mounted) {
      _onSuccess();
    } else if (!success && auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isLoading = auth.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),

                  // Brand Header Badge
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(child: LogoWidget(size: 28)),
                  ),
                  const SizedBox(height: 14),

                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                      children: [
                        TextSpan(
                          text: 'Gadget ',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        TextSpan(
                          text: 'Store',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Welcome Title
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sign in or create an account to get started',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Google Sign-In Option
                  GoogleButton(
                    isLoading: isLoading,
                    onPressed: _loginWithGoogle,
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'or continue with mobile',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Phone / OTP Input Section
                  if (!_isOtpSent) ...[
                    CustomTextField(
                      label: 'Phone Number',
                      hintText: '98765 43210',
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      prefixWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              _selectedCountryCode,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 20,
                              color: const Color(0xFFCBD5E1),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    LoadingButton(
                      text: 'Send OTP',
                      isLoading: isLoading,
                      onPressed: _sendOtp,
                    ),
                  ] else ...[
                    // OTP Verification UI
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'OTP sent to $_selectedCountryCode ${_phoneController.text}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _isOtpSent = false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    OTPInput(length: 6, onChanged: (val) => _currentOtp = val),

                    const SizedBox(height: 20),

                    LoadingButton(
                      text: 'Verify OTP',
                      isLoading: isLoading,
                      onPressed: _verifyOtp,
                    ),

                    const SizedBox(height: 16),

                    if (_otpCooldownSeconds > 0)
                      Text(
                        'Resend OTP in $_otpCooldownSeconds seconds',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: _sendOtp,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 28),

                  // Terms & Privacy Notice
                  const Text(
                    'By continuing, you agree to GadgetWorld Terms of Service & Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
