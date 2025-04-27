import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _role = 'customer';
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      Navigator.pushReplacementNamed(context, '/landing');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('assets/bahirmart_logo.png', height: 120),
                  SizedBox(height: 32),
                  // Full Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                    onChanged: (value) => _fullName = value,
                  ),
                  SizedBox(height: 16),
                  // Email Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
                    onChanged: (value) => _email = value,
                  ),
                  SizedBox(height: 16),
                  // Password Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) =>
                        value!.length < 6 ? 'Password must be at least 6 characters' : null,
                    onChanged: (value) => _password = value,
                  ),
                  SizedBox(height: 16),
                  // Confirm Password Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) => value != _password ? 'Passwords do not match' : null,
                    onChanged: (value) => _confirmPassword = value,
                  ),
                  SizedBox(height: 16),
                  // Role Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: 'customer',
                        groupValue: _role,
                        onChanged: (value) => setState(() => _role = value!),
                      ),
                      Text('Customer', style: TextStyle(color: Colors.white)),
                      Radio<String>(
                        value: 'merchant',
                        groupValue: _role,
                        onChanged: (value) => setState(() => _role = value!),
                      ),
                      Text('Merchant', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 32),
                  // Sign Up Button
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                  SizedBox(height: 16),
                  // Sign In Link
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signin'),
                    child: Text(
                      'Already have an account? Sign In',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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