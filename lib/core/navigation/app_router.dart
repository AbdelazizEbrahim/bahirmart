import 'package:bahirmart/pages/orders_page.dart';
import 'package:bahirmart/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:bahirmart/pages/landing_page.dart';
import 'package:bahirmart/pages/products_page.dart';
import 'package:bahirmart/pages/product_detail_page.dart';
import 'package:bahirmart/pages/auctions_page.dart';
import 'package:bahirmart/pages/cart_page.dart';
import 'package:bahirmart/core/models/product_model.dart' as prod_model;
import 'package:bahirmart/pages/notifications_page.dart';
import 'package:bahirmart/pages/sign_in_page.dart';
import 'package:bahirmart/pages/sign_up_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => const NotificationsPage(),
        );
      case '/profile':
        return MaterialPageRoute(
          builder: (_) =>
              const ProfilePage(), // Replace with your actual ProfilePage widget
        );
      case '/orders':
        return MaterialPageRoute(
          builder: (_) => const OrdersPage(), // Use the OrdersPage widget
        );
      case '/settings':
        return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Settings Page'))));
      case '/products':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProductsPage(
            categoryId: args?['categoryId'] as String?,
            title: args?['title'] as String? ?? 'Products',
            searchPhrase: args?['searchPhrase'] as String?,
          ),
        );
      case '/auctions':
        return MaterialPageRoute(builder: (_) => const AuctionListPage());
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartPage());
      case '/more':
        return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('More Page'))));
      case '/product_detail':
        final product = settings.arguments as prod_model.Product?;
        if (product == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Product not found')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ProductDetailPage(product: product),
        );
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInPage());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      default:
        return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Center(child: Text('Page Not Found'))));
    }
  }
}
