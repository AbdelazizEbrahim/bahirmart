import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:bahirmart/core/models/user_model.dart';
import 'package:bahirmart/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class AuthService {
  static const String _baseUrl = 'https://api.bahirmart.com/api/v1';
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'https://www.googleapis.com/auth/userinfo.profile'],
  );

  static Future<void> signInWithEmail(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/signin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
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
        throw Exception('Failed to sign in: ${response.body}');
      }
    } catch (e) {
      debugPrint('Sign-in error: $e');
      throw Exception('Sign-in failed: ${e.toString()}');
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
        Uri.parse('$_baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        debugPrint('Sign-up successful');
      } else {
        throw Exception('Failed to sign up: ${response.body}');
      }
    } catch (e) {
      debugPrint('Sign-up error: $e');
      throw Exception('Sign-up failed: ${e.toString()}');
    }
  }

  static Future<void> verifyOtp(String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otp': otp.trim()}),
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
        throw Exception('Failed to verify OTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('OTP verification error: $e');
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  static Future<void> resendOtp() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/resend-otp'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('OTP resent successfully');
      } else {
        throw Exception('Failed to resend OTP: ${response.body}');
      }
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      throw Exception('Failed to resend OTP: ${e.toString()}');
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
          'Authorization': apiKey,
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
}