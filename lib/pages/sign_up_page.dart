import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/services/auth_service.dart';
import 'package:bahirmart/components/custom_button.dart';
import 'package:bahirmart/components/custom_text_field.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

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
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();

  String _selectedRole = 'customer';
  String? _selectedBankSlug;
  List<Map<String, dynamic>> _banks = [];
  bool _isLoading = false;
  File? _tinFile;
  File? _nationalIdFile;
  String? _tinFileUrl;
  String? _nationalIdFileUrl;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _fetchBanks();
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
        SnackBar(content: Text('Firebase initialization failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchBanks() async {
    try {
      final banks = await AuthService.getBanks();
      setState(() {
        _banks = banks;
        if (banks.isNotEmpty && _selectedBankSlug == null) {
          _selectedBankSlug = banks[0]['slug'] as String?;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load banks: ${e.toString()}')),
      );
    }
  }

  Future<String?> _uploadFile(File file, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File upload failed: ${e.toString()}')),
      );
      return null;
    }
  }

  Future<void> _pickFile(bool isTin) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          if (isTin) {
            _tinFile = File(result.files.single.path!);
          } else {
            _nationalIdFile = File(result.files.single.path!);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: ${e.toString()}')),
      );
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? tinUrl;
        String? nationalIdUrl;

        if (_selectedRole == 'merchant') {
          if (_tinFile == null || _nationalIdFile == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please upload both TIN and National ID documents')),
            );
            setState(() => _isLoading = false);
            return;
          }

          tinUrl = await _uploadFile(_tinFile!, 'tin/${_emailController.text}_${DateTime.now().millisecondsSinceEpoch}');
          nationalIdUrl = await _uploadFile(_nationalIdFile!, 'national_id/${_emailController.text}_${DateTime.now().millisecondsSinceEpoch}');

          if (tinUrl == null || nationalIdUrl == null) {
            setState(() => _isLoading = false);
            return;
          }
        }

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
              'tinNumberUrl': tinUrl,
              'nationalIdUrl': nationalIdUrl,
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
                      setState(() {
                        _selectedRole = value!;
                        _selectedBankSlug = _banks.isNotEmpty ? _banks[0]['slug'] as String? : null;
                      });
                    },
                  ),
                  const Text('Customer'),
                  Radio<String>(
                    value: 'merchant',
                    groupValue: _selectedRole,
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                        _selectedBankSlug = _banks.isNotEmpty ? _banks[0]['slug'] as String? : null;
                      });
                    },
                  ),
                  const Text('Merchant'),
                ],
              ),
              if (_selectedRole == 'merchant') ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickFile(true),
                  child: Text(_tinFile == null ? 'Upload TIN Document' : 'TIN Document Selected'),
                ),
                if (_tinFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Selected: ${_tinFile!.path.split('/').last}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickFile(false),
                  child: Text(_nationalIdFile == null ? 'Upload National ID Document' : 'National ID Document Selected'),
                ),
                if (_nationalIdFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Selected: ${_nationalIdFile!.path.split('/').last}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBankSlug,
                  decoration: const InputDecoration(
                    labelText: 'Select Bank',
                    border: OutlineInputBorder(),
                  ),
                  items: _banks
                      .where((bank) => bank['slug'] != null)
                      .map((bank) {
                        return DropdownMenuItem<String>(
                          value: bank['slug'] as String,
                          child: Text(bank['name'] as String? ?? 'Unknown Bank'),
                        );
                      })
                      .toList(),
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
                      final expectedLength = selectedBank['acct_length'] as int? ?? 0;
                      if (expectedLength == 0 || value.length != expectedLength) {
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
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }
}

// Updated getBanks function
Future<List<Map<String, dynamic>>> getBanks() async {
  try {
    final apiKey = dotenv.env['CHAPA_SECRET_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('CHAPA_SECRET_KEY is not set in .env');
    }

    final response = await http.get(
      Uri.parse('https://api.chapa.co/v1/banks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['data'] == null || data['data'] is! List) {
        throw Exception('Invalid response format: No bank data found');
      }

      // Extract name, acct_length, and slug from each bank
      final List<Map<String, dynamic>> banks = List<Map<String, dynamic>>.from(data['data'])
          .asMap()
          .entries
          .map((entry) {
            final bank = entry.value;
            return {
              'name': bank['name'] as String? ?? 'Unknown Bank',
              'acct_length': bank['acct_length'] as int? ?? 10,
              'slug': bank['slug'] as String? ?? 'bank_${entry.key}',
            };
          })
          .where((bank) => bank['slug'] != null)
          .toList();

      return banks;
    } else {
      throw Exception('Failed to fetch banks: ${response.body}');
    }
  } catch (e) {
    debugPrint('Fetch banks error: $e');
    throw Exception('Failed to fetch banks: ${e.toString()}');
  }
}