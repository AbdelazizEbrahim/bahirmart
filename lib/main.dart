import 'package:flutter/material.dart';
import 'pages/auth/sign_in_page.dart';
import 'pages/auth/sign_up_page.dart';
import 'pages/home_screen.dart';
import 'pages/profile_page.dart';
// import 'pages/orders_page.dart';
// import 'pages/settings_page.dart';
// import 'pages/products_page.dart';
// import 'pages/auctions_page.dart';
// import 'pages/cart_page.dart';
// import 'pages/placeholder_page.dart';

void main() {
  runApp(BahirmartApp());
}

class BahirmartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahirmart',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/signin': (context) => SignInPage(),
        '/signup': (context) => SignUpPage(),
        '/profile': (context) => ProfilePage(),
        // '/orders': (context) => OrdersPage(),
        // '/settings': (context) => SettingsPage(),
        // '/products': (context) => ProductsPage(),
        // '/auctions': (context) => AuctionsPage(),
        // '/cart': (context) => CartPage(),
        // '/placeholder': (context) => PlaceholderPage(),
      },
    );
  }
}