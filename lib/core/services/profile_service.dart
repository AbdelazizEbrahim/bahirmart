import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bahirmart/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/main.dart';

class ProfileService {
  Future<void> fetchUserProfile(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to view your profile'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.35.75:4000/api/mobile-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final user = User(
          id: userData['_id'] ?? '',
          fullName: userData['fullName'] ?? '',
          email: userData['email'] ?? '',
          password: '',
          role: userData['role'] ?? 'customer',
          image: userData['image'] ?? '',
          isBanned: userData['isBanned'] ?? false,
          isEmailVerified: userData['isEmailVerified'] ?? true,
          isDeleted: userData['isDeleted'] ?? false,
          phoneNumber: userData['phoneNumber'] ?? '',
          stateName: userData['stateName'] ?? '',
          cityName: userData['cityName'] ?? '',
        );
        Provider.of<UserProvider>(context, listen: false).setUser(user);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch profile: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateProfile(
      BuildContext context, Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.put(
        Uri.parse('http://192.168.35.75:4000/api/mobile-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fullName': profileData['fullName'],
          'phoneNumber': profileData['phoneNumber'],
          'stateName': profileData['stateName'],
          'cityName': profileData['cityName'],
          'image': profileData['image'],
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        Provider.of<UserProvider>(context, listen: false).setUser(
          User(
            id: userData['_id'] ?? '',
            fullName: userData['fullName'] ?? '',
            email: userData['email'] ?? '',
            password: '',
            role: userData['role'] ?? 'customer',
            image: userData['image'] ?? '',
            isBanned: userData['isBanned'] ?? false,
            isEmailVerified: userData['isEmailVerified'] ?? true,
            isDeleted: userData['isDeleted'] ?? false,
            phoneNumber: userData['phoneNumber'] ?? '',
            stateName: userData['stateName'] ?? '',
            cityName: userData['cityName'] ?? '',
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> changePassword(
      BuildContext context, Map<String, String> passwordData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final baseUrl = dotenv.env['BASE_URL'];

      final response = await http.put(Uri.parse('$baseUrl/mobile-password'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'currentPassword': passwordData['currentPassword'],
            'newPassword': passwordData['newPassword'],
          }));
          
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change password: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error changing password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
