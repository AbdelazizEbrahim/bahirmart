import 'package:flutter/material.dart';
import 'package:bahirmart/core/constants/app_colors.dart';

class BahirMartBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const BahirMartBottomNavigationBar({Key? key, required this.currentIndex})
      : super(key: key);

  void _onTabTapped(BuildContext context, int index) {
    final routes = ['/', '/products', '/auctions', '/cart', '/more'];
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      onTap: (index) => _onTabTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Products'),
        BottomNavigationBarItem(icon: Icon(Icons.gavel), label: 'Auctions'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
      ],
    );
  }
}
