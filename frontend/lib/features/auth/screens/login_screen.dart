import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/theme.dart';
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
  final TextEditingController _phoneController = TextEditingController(text: '+91 ');

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _onSuccess() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
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
    if (_phoneController.text.isEmpty) {
      _showError('Please enter phone number (with country code)');
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.sendOTP(_phoneController.text);
    if (success) {
      setState(() => _isOtpSent = true);
      _startOtpCooldown();
    } else if (auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
    }
  }

  Future<void> _verifyOtp() async {
    if (_currentOtp.length != 6) {
      _showError('Please enter a 6-digit OTP');
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.verifyOTP(_phoneController.text, _currentOtp);
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const LogoWidget(size: 48),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 20, color: AppTheme.black),
                  children: [
                    TextSpan(text: 'Gadget ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Store', style: TextStyle(fontWeight: FontWeight.w300)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.black),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in or create an account',
                style: TextStyle(fontSize: 14, color: AppTheme.greyText),
              ),
              const SizedBox(height: 40),

              GoogleButton(
                isLoading: isLoading,
                onPressed: _loginWithGoogle,
              ),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.greyBorder)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or continue with mobile', style: TextStyle(color: AppTheme.greyText.withValues(alpha: 0.5))),
                  ),
                  const Expanded(child: Divider(color: AppTheme.greyBorder)),
                ],
              ),
              const SizedBox(height: 24),

              if (!_isOtpSent) ...[
                CustomTextField(
                  label: 'Phone Number',
                  hintText: '+1234567890',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  text: 'Send OTP',
                  isLoading: isLoading,
                  onPressed: _sendOtp,
                ),
              ] else ...[
                OTPInput(
                  length: 6,
                  onChanged: (val) => _currentOtp = val,
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  text: 'Verify OTP',
                  isLoading: isLoading,
                  onPressed: _verifyOtp,
                ),
                const SizedBox(height: 16),
                if (_otpCooldownSeconds > 0)
                  Text('Resend OTP in $_otpCooldownSeconds seconds', style: const TextStyle(fontSize: 13, color: AppTheme.greyText))
                else
                  TextButton(
                    onPressed: _sendOtp,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: const Text('Resend OTP', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black, decoration: TextDecoration.underline)),
                  ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
