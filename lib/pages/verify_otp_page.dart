import 'package:flutter/material.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/services/auth_service.dart';
import 'package:bahirmart/components/custom_button.dart';
import 'package:bahirmart/components/custom_text_field.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({Key? key}) : super(key: key);

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _emailController = TextEditingController(); // For manual email input
  bool _isLoading = false;
  String? email;
  int _resendAttempts = 0;
  static const int _maxResendAttempts = 3;

  @override
  void initState() {
    super.initState();
    print('VerifyOtpPage: [${DateTime.now()}] initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      print('VerifyOtpPage: [${DateTime.now()}] Navigation arguments: $arguments');
      if (arguments is String && arguments.isNotEmpty && RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(arguments)) {
        email = arguments;
        _emailController.text = email!;
        print('VerifyOtpPage: [${DateTime.now()}] Email received: $email');
      } else {
        print('VerifyOtpPage: [${DateTime.now()}] Error - Invalid or null arguments: $arguments');
        email = null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid or missing email. Please enter it manually.')),
        );
      }
      setState(() {});
    });
  }

  Future<void> _verifyOtp() async {
    print('VerifyOtpPage: [${DateTime.now()}] Verify OTP button pressed');
    if (_formKey.currentState!.validate()) {
      final inputEmail = _emailController.text.trim();
      if (inputEmail.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(inputEmail)) {
        print('VerifyOtpPage: [${DateTime.now()}] Error - Invalid email: $inputEmail');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address')),
        );
        return;
      }
      email = inputEmail;

      print('VerifyOtpPage: [${DateTime.now()}] Form validation passed, OTP: ${_otpController.text}, Email: $email');
      setState(() {
        _isLoading = true;
        print('VerifyOtpPage: [${DateTime.now()}] Setting isLoading to true');
      });
      try {
        await AuthService.verifyOtp(_otpController.text, email!).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Verification request timed out');
          },
        );
        print('VerifyOtpPage: [${DateTime.now()}] OTP verification successful, navigating to home');
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        print('VerifyOtpPage: [${DateTime.now()}] OTP verification failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP verification failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
          print('VerifyOtpPage: [${DateTime.now()}] Setting isLoading to false');
        });
      }
    } else {
      print('VerifyOtpPage: [${DateTime.now()}] Form validation failed');
    }
  }

  Future<void> _resendOtp() async {
    print('VerifyOtpPage: [${DateTime.now()}] Resend OTP button pressed');
    final inputEmail = _emailController.text.trim();
    if (inputEmail.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(inputEmail)) {
      print('VerifyOtpPage: [${DateTime.now()}] Error - Invalid email for resend: $inputEmail');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    email = inputEmail;

    if (_resendAttempts >= _maxResendAttempts) {
      print('VerifyOtpPage: [${DateTime.now()}] Max resend attempts reached: $_resendAttempts');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum resend attempts reached. Please try again later.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      print('VerifyOtpPage: [${DateTime.now()}] Setting isLoading to true for resend');
    });
    try {
      print('VerifyOtpPage: [${DateTime.now()}] Resending OTP for email: $email');
      await AuthService.resendOtp(email!).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Resend OTP request timed out');
        },
      );
      _resendAttempts++;
      print('VerifyOtpPage: [${DateTime.now()}] OTP resent successfully, attempt: $_resendAttempts');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP has been resent to your email')),
      );
    } catch (e) {
      print('VerifyOtpPage: [${DateTime.now()}] Resend OTP failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resend OTP failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        print('VerifyOtpPage: [${DateTime.now()}] Setting isLoading to false after resend');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('VerifyOtpPage: [${DateTime.now()}] Building UI, email: $email');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                email != null && email!.isNotEmpty
                    ? 'Enter the OTP sent to $email'
                    : 'Enter your email and the OTP sent',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (email == null || email!.isEmpty)
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      print('VerifyOtpPage: [${DateTime.now()}] Email validation failed - empty');
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      print('VerifyOtpPage: [${DateTime.now()}] Email validation failed - invalid format');
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _otpController,
                label: 'OTP',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    print('VerifyOtpPage: [${DateTime.now()}] OTP validation failed - empty');
                    return 'Please enter the OTP';
                  }
                  if (value.length != 6) {
                    print('VerifyOtpPage: [${DateTime.now()}] OTP validation failed - length not 6');
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Verify OTP',
                onPressed: _isLoading ? null : _verifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _resendOtp,
                child: const Text('Resend OTP'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        print('VerifyOtpPage: [${DateTime.now()}] Back to signup pressed');
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                child: const Text('Back to Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('VerifyOtpPage: [${DateTime.now()}] Disposing, cleaning up controllers');
    _otpController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}