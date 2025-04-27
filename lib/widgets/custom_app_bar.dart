import 'package:flutter/material.dart';
import '../utils/navigation.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Bahirmart'),
      backgroundColor: Colors.blue.shade700,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No new notifications')),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.blue.shade700),
          ),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                Navigator.pushNamed(context, '/profile');
                break;
              case 'orders':
                Navigator.pushNamed(context, '/orders');
                break;
              case 'settings':
                Navigator.pushNamed(context, '/settings');
                break;
              case 'logout':
                NavigationHelper.logout(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'profile', child: Text('Profile')),
            PopupMenuItem(value: 'orders', child: Text('Orders')),
            PopupMenuItem(value: 'settings', child: Text('Settings')),
            PopupMenuItem(value: 'logout', child: Text('Logout')),
          ],
        ),
      ],
    );
  }
}