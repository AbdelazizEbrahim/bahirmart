import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/services/auth_service.dart';
import 'package:bahirmart/components/custom_button.dart';
import 'package:bahirmart/components/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBXfW7yS26URkiumrxEX0E3COUl5GU2fVk',
          authDomain: 'food-ordering-app-36d12.firebaseapp.com',
          projectId: 'food-ordering-app-36d12',
          storageBucket: 'food-ordering-app-36d12.appspot.com',
          messagingSenderId: '349793603398',
          appId: '1:349793603398:web:dd58bc31697be029bddf47',
          measurementId: 'G-6KFWNLBD4B',
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Firebase initialization failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _signUp() async {
    print('SignUp: [${DateTime.now()}] SignUp button pressed');
    if (_formKey.currentState!.validate()) {
      // Validate email format
      final email = _emailController.text.trim();
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        print('SignUp: [${DateTime.now()}] Invalid email format: $email');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });
      try {
        final userData = {
          'fullName': _fullNameController.text.trim(),
          'email': email,
          'password': _passwordController.text,
          'role': 'customer',
          'phoneNumber': _phoneController.text.trim(),
          'stateName': _stateController.text.trim(),
          'cityName': _cityController.text.trim(),
        };
        print(
            'SignUp: [${DateTime.now()}] Sending userData to signUp: $userData');

        final response = await AuthService.signUp(userData);
        Navigator.pushNamed(context, '/verify-otp', arguments: email);
      } catch (e) {
        String errorMessage = 'Signup failed. Please try again.';
        if (e.toString().contains('email')) {
          errorMessage = 'Failed to send OTP email. Check your email address.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _fullNameController,
                label: 'Full Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _stateController,
                label: 'State',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cityController,
                label: 'City',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Sign Up',
                onPressed: _isLoading ? null : _signUp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
