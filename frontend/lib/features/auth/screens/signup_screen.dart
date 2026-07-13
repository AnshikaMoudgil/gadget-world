import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/core/widgets/custom_text_field.dart';
import 'package:gadget_store/core/widgets/logo_widget.dart';
import 'package:gadget_store/features/auth/providers/auth_provider.dart';
import 'package:gadget_store/features/auth/widgets/loading_button.dart';
import 'package:gadget_store/features/auth/widgets/google_button.dart';
import 'package:gadget_store/features/auth/widgets/otp_input.dart';
import 'package:gadget_store/features/home/screens/main_screen.dart';
import '../services/google_auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController(text: '+91 ');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneLoginController = TextEditingController(text: '+91 ');

  double _passwordStrength = 0.0;
  bool _isPhoneMode = false;
  bool _isOtpSent = false;
  String _currentOtp = '';
  String? _lastError;
  Timer? _otpCooldownTimer;
  int _otpCooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    GoogleAuthService.isSignUpIntent = true;
    _passwordController.addListener(() {
      _calculatePasswordStrength(_passwordController.text);
    });
    GoogleAuthService.authSuccessStream.stream.listen((_) {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      auth.addListener(_onAuthChange);
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
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneLoginController.dispose();
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

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  void _calculatePasswordStrength(String value) {
    double strength = 0;
    if (value.length >= 8) strength += 0.25;
    if (value.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (value.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    setState(() {
      _passwordStrength = strength;
    });
  }

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError('All fields are required');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      _showError('Invalid email format');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (_passwordStrength < 0.75) {
      _showError('Please use a stronger password');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signUpWithEmail(
      _emailController.text, 
      _passwordController.text,
      fullName: _nameController.text,
      mobileNumber: _mobileController.text,
    );
    
    if (success && mounted) {
      _showSuccess('Account created successfully! Please verify your email.');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } else if (!success && auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
    }
  }

  Future<void> _signUpWithGoogle() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle(isSignUp: true);
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } else if (!success && auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
    }
  }

  Future<void> _sendOtp() async {
    if (_phoneLoginController.text.isEmpty) {
      _showError('Please enter phone number (with country code)');
      return;
    }
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.sendOTP(_phoneLoginController.text);
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
    final success = await auth.verifyOTP(_phoneLoginController.text, _currentOtp, isSignUp: true);
    if (success && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } else if (!success && auth.errorMessage != null && mounted) {
      _showError(auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create your account',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isPhoneMode 
                            ? (_isOtpSent ? 'Enter OTP sent to your phone' : 'Sign up using your mobile number') 
                            : 'Join Gadget World and grow your business\nwith better prices and service.',
                          style: const TextStyle(fontSize: 14, color: AppTheme.greyText),
                        ),
                      ],
                    ),
                  ),
                  const LogoWidget(size: 60),
                ],
              ),
              const SizedBox(height: 32),

              if (_isPhoneMode) ...[
                if (!_isOtpSent) ...[
                  CustomTextField(
                    label: 'Phone Number',
                    hintText: '+1234567890',
                    prefixIcon: Icons.phone_outlined,
                    controller: _phoneLoginController,
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    text: 'Send OTP',
                    isLoading: auth.isLoading,
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
                    isLoading: auth.isLoading,
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
                  child: const Text('Sign up with Email instead', style: TextStyle(color: AppTheme.black, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                CustomTextField(
                  label: 'Name',
                  hintText: 'Enter your name',
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Email address',
                  hintText: 'you@business.com',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Mobile Number',
                  hintText: '+1234567890',
                  prefixIcon: Icons.phone_outlined,
                  controller: _mobileController,
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Password',
                  hintText: 'Enter password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Container(height: 4, color: _passwordStrength > 0 ? AppTheme.black : AppTheme.greyBorder)),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 4, color: _passwordStrength > 0.25 ? AppTheme.black : AppTheme.greyBorder)),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 4, color: _passwordStrength > 0.5 ? AppTheme.black : AppTheme.greyBorder)),
                    const SizedBox(width: 4),
                    Expanded(child: Container(height: 4, color: _passwordStrength > 0.75 ? AppTheme.black : AppTheme.greyBorder)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Password strength: ${_passwordStrength < 0.5 ? 'Weak' : _passwordStrength < 1.0 ? 'Medium' : 'Strong'}',
                  style: TextStyle(
                    color: _passwordStrength < 0.5 ? AppTheme.error : (_passwordStrength < 1.0 ? Colors.orange : Colors.green),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Confirm password',
                  hintText: 'Confirm password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 32),
                LoadingButton(
                  text: 'Create Account',
                  isLoading: auth.isLoading,
                  onPressed: _signUp,
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
                  isLoading: auth.isLoading,
                  onPressed: _signUpWithGoogle,
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
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: AppTheme.greyText)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Log in',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.black, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
