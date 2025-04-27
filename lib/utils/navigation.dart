import 'package:flutter/material.dart';

class NavigationHelper {
  static void logout(BuildContext context) {
    // Simulate logout (clear session, etc.)
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }
}