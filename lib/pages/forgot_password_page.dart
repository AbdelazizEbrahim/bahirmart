import 'package:flutter/material.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/services/auth_service.dart';
import 'package:bahirmart/components/custom_button.dart';
import 'package:bahirmart/components/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  int _currentStep = 1; // 1: Email, 2: OTP, 3: Password
  String? _email; // Store email for subsequent steps
  String? _otp; // Store OTP locally

  Future<void> _sendResetCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService.sendPasswordResetCode(_emailController.text);
        setState(() {
          _email = _emailController.text;
          _currentStep = 2; // Move to OTP step
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset code sent to your email')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_email == null) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.resendOtp(_email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New reset code sent to your email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _storeOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _otp = _codeController.text; // Store OTP locally
        _currentStep = 3; // Move to password step
      });
    }
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService.updatePassword(
          _email!,
          _otp!,
          _passwordController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
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
                _currentStep == 1
                    ? 'Enter your email to receive a reset code'
                    : _currentStep == 2
                        ? 'Enter the reset code sent to your email'
                        : 'Enter your new password',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              if (_currentStep == 1) ...[
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Send Reset Code',
                  onPressed: _isLoading ? null : _sendResetCode,
                  isLoading: _isLoading,
                ),
              ] else if (_currentStep == 2) ...[
                CustomTextField(
                  controller: _codeController,
                  label: 'Reset Code',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the reset code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  child: const Text('Resend Code'),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Continue',
                  onPressed: _isLoading ? null : _storeOtp,
                  isLoading: _isLoading,
                ),
              ] else if (_currentStep == 3) ...[
                CustomTextField(
                  controller: _passwordController,
                  label: 'New Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Update Password',
                  onPressed: _isLoading ? null : _updatePassword,
                  isLoading: _isLoading,
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  if (_currentStep == 1) {
                    Navigator.pop(context);
                  } else {
                    setState(() => _currentStep = _currentStep - 1);
                  }
                },
                child: Text(_currentStep == 1 ? 'Back to Sign In' : 'Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}