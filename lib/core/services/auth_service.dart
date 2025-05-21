import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bahirmart/core/models/user_model.dart';
import 'package:bahirmart/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For debugPrint

class AuthService {
  static const String _baseUrl = 'http://192.168.219.23:3001/api';
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  static Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    final url = Uri.parse('$_baseUrl/mobile-login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_email', data['user']['email']);

      final storedToken = prefs.getString('auth_token');
      if (storedToken != null && storedToken.isNotEmpty) {
        print('Token stored successfully: $storedToken');
      } else {
        print('Failed to store token.');
      }

      // ✅ Redirect to home after successful login
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Login failed';
      throw Exception(error);
    }
  }

  static Future<List<Map<String, dynamic>>> getBanks() async {
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
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Failed to fetch banks: ${response.body}');
      }
    } catch (e) {
      debugPrint('Fetch banks error: $e');
      throw Exception('Failed to fetch banks: ${e.toString()}');
    }
  }

  static Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled by user');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('Failed to retrieve Google ID token');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['user'] == null) {
          throw Exception('Invalid response: No user data found');
        }
        final user = User.fromJson(data['user']);
        final context = navigatorKey.currentContext;
        if (context == null) {
          throw Exception('Navigator context is null');
        }
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      } else {
        throw Exception('Failed to sign in with Google: ${response.body}');
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  static Future<void> signUp(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        debugPrint('Sign-up successful');
        final email = userData['email'] as String?;

        await sendOtp(email!, 'verify');
      } else {
        throw Exception('Failed to sign up: ${response.body}');
      }
    } catch (e) {
      debugPrint('Sign-up error: $e');
      throw Exception('Sign-up failed: ${e.toString()}');
    }
  }

  static Future<void> verifyOtp(String otp, String email) async {
    print(
        'AuthService: [${DateTime.now()}] Initiating OTP verification for email: $email');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp': otp.trim(),
          'email': email.trim(),
        }),
      );

      print(
          'AuthService: [${DateTime.now()}] OTP verification response status: ${response.statusCode}');
      print('AuthService: [${DateTime.now()}] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final context = navigatorKey.currentContext;
        if (context == null) {
          print('AuthService: [${DateTime.now()}] Navigator context is null');
          throw Exception('Navigator context is null');
        }

        print('AuthService: [${DateTime.now()}] Redirecting to /signin...');
        Navigator.pushNamed(context, '/signin');
      } else {
        print(
            'AuthService: [${DateTime.now()}] OTP verification failed with status: ${response.statusCode}');
        throw Exception('Failed to verify OTP: ${response.body}');
      }
    } catch (e) {
      print('AuthService: [${DateTime.now()}] OTP verification error: $e');
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  static Future<void> sendOtp(String email, String type) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sendOtp?type=$type'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to send OTP');
      }
      debugPrint('OTP sent successfully to $email');
    } catch (e) {
      debugPrint('Send OTP error: $e');
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  static Future<void> resendOtp(String email) async {
    try {
      await sendOtp(email, 'verify');
      debugPrint('OTP resent successfully');
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      throw Exception('Failed to resend OTP: ${e.toString()}');
    }
  }

  static Future<void> sendPasswordResetCode(String email) async {
    try {
      await sendOtp(email, 'reset');
      debugPrint('Password reset code sent successfully to $email');
    } catch (e) {
      debugPrint('Send password reset code error: $e');
      throw Exception('Failed to send password reset code: ${e.toString()}');
    }
  }

  static Future<void> verifyResetCode(String email, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verifyOtp?action=reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to verify reset code');
      }
      debugPrint('Reset code verified successfully');
    } catch (e) {
      debugPrint('Verify reset code error: $e');
      throw Exception('Failed to verify reset code: ${e.toString()}');
    }
  }

  static Future<void> updatePassword(
      String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verifyOtp?action=reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': code,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to update password');
      }
      debugPrint('Password updated successfully');
    } catch (e) {
      debugPrint('Update password error: $e');
      throw Exception('Failed to update password: ${e.toString()}');
    }
  }
}
