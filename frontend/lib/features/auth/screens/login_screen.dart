import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/custom_text_field.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/features/auth/providers/auth_provider.dart';
import 'package:gadget_store/features/auth/screens/signup_screen.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';
import 'package:gadget_store/features/auth/screens/forgot_password_screen.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '+91 ');

  bool _isPhoneMode = false;
  bool _isOtpSent = false;
  String _currentOtp = '';
  String? _lastError;
  Timer? _otpCooldownTimer;
  int _otpCooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    GoogleAuthService.isSignUpIntent = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.addListener(_onAuthChange);
    });
    
    GoogleAuthService.authSuccessStream.stream.listen((_) {
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

  void dispose() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.removeListener(_onAuthChange);
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpCooldownTimer?.cancel();
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

  Future<void> _loginWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithEmail(_emailController.text, _passwordController.text);
    if (success && mounted) _onSuccess();
    else if (!success && auth.errorMessage != null && mounted) _showError(auth.errorMessage!);
  }

  Future<void> _loginWithGoogle() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle();
    if (success && mounted) _onSuccess();
    else if (!success && auth.errorMessage != null && mounted) _showError(auth.errorMessage!);
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
    if (success && mounted) _onSuccess();
    else if (!success && auth.errorMessage != null && mounted) _showError(auth.errorMessage!);
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
              Text(
                _isPhoneMode ? 'Phone Login' : 'Welcome back',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.black),
              ),
              const SizedBox(height: 8),
              Text(
                _isPhoneMode 
                  ? (_isOtpSent ? 'Enter OTP sent to your phone' : 'Login using your mobile number') 
                  : 'Login to access your account',
                style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
              ),
              const SizedBox(height: 40),
              
              if (_isPhoneMode) ...[
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
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isPhoneMode = false;
                      _isOtpSent = false;
                    });
                  },
                  child: const Text('Login with Email instead', style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                CustomTextField(
                  label: 'Email address',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                LoadingButton(
                  text: 'Login',
                  isLoading: isLoading,
                  onPressed: _loginWithEmail,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.greyBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or', style: TextStyle(color: AppTheme.greyText.withOpacity(0.5))),
                    ),
                    const Expanded(child: Divider(color: AppTheme.greyBorder)),
                  ],
                ),
                const SizedBox(height: 16),
                GoogleButton(
                  isLoading: isLoading,
                  onPressed: _loginWithGoogle,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isPhoneMode = true;
                    });
                  },
                  icon: const Icon(Icons.phone_android, color: AppTheme.black),
                  label: const Text('Continue with Mobile', style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? ', style: TextStyle(color: AppTheme.greyText)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
