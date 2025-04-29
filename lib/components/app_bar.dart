import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';
import 'package:bahirmart/main.dart';

class BahirMartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BahirMartAppBar({Key? key, required String title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return AppBar(
      backgroundColor: AppColors.primary,
      title: const Text('BahirMart'),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        if (userProvider.user != null)
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundImage: userProvider.user!.image.isNotEmpty
                  ? NetworkImage(userProvider.user!.image)
                  : const AssetImage('assets/placeholder.png') as ImageProvider,
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
                  Provider.of<UserProvider>(context, listen: false).setUser(null);
                  Navigator.pushReplacementNamed(context, '/login');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              const PopupMenuItem(value: 'orders', child: Text('Orders')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}