import 'package:flutter/material.dart';
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
  final _tinNumberController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  String _selectedRole = 'customer';
  String? _selectedBankSlug;
  List<Map<String, dynamic>> _banks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchBanks();
  }

  Future<void> _fetchBanks() async {
    try {
      final banks = await AuthService.getBanks();
      setState(() {
        _banks = banks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load banks: ${e.toString()}')),
      );
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userData = {
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _selectedRole,
          'phoneNumber': _phoneController.text,
          'address': {
            'state': _stateController.text,
            'city': _cityController.text,
          },
          if (_selectedRole == 'merchant') ...{
            'merchantDetails': {
              'tinNumber': _tinNumberController.text,
              'nationalId': _nationalIdController.text,
              'account': {
                'name': _accountNameController.text,
                'number': _accountNumberController.text,
                'bankCode': _selectedBankSlug,
              },
            },
          },
        };

        await AuthService.signUp(userData);
        Navigator.pushNamed(context, '/verify-otp');
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
              const SizedBox(height: 16),
              const Text('Select Role:'),
              Row(
                children: [
                  Radio<String>(
                    value: 'customer',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() => _selectedRole = value!);
                    },
                  ),
                  const Text('Customer'),
                  Radio<String>(
                    value: 'merchant',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() => _selectedRole = value!);
                    },
                  ),
                  const Text('Merchant'),
                ],
              ),
              if (_selectedRole == 'merchant') ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _tinNumberController,
                  label: 'TIN Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your TIN number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _nationalIdController,
                  label: 'National ID',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your national ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBankSlug,
                  decoration: const InputDecoration(
                    labelText: 'Select Bank',
                    border: OutlineInputBorder(),
                  ),
                  items: _banks.map((bank) {
                    return DropdownMenuItem<String>(
                      value: bank['slug'] as String,
                      child: Text(bank['name'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedBankSlug = value);
                  },
                  validator: (value) {
                    if (_selectedRole == 'merchant' && (value == null || value.isEmpty)) {
                      return 'Please select a bank';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _accountNameController,
                  label: 'Account Name',
                  validator: (value) {
                    if (_selectedRole == 'merchant' && (value == null || value.isEmpty)) {
                      return 'Please enter account name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _accountNumberController,
                  label: 'Account Number',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_selectedRole == 'merchant') {
                      if (value == null || value.isEmpty) {
                        return 'Please enter account number';
                      }
                      final selectedBank = _banks.firstWhere(
                        (bank) => bank['slug'] == _selectedBankSlug,
                        orElse: () => {'acct_length': 0},
                      );
                      final expectedLength = selectedBank['acct_length'] as int?;
                      if (expectedLength == null || value.length != expectedLength) {
                        return 'Account number must be $expectedLength digits';
                      }
                    }
                    return null;
                  },
                ),
              ],
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
    _tinNumberController.dispose();
    _nationalIdController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}