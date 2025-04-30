import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/main.dart';

class BahirMartAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const BahirMartAppBar({
    Key? key,
    required this.title,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Default actions (notifications and user menu)
    final List<Widget> defaultActions = [
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
    ];

    // Combine custom actions with default actions
    final List<Widget> combinedActions = [
      if (actions != null) ...actions!, // Spread custom actions if not null
      ...defaultActions,               // Spread default actions
    ];

    return AppBar(
      backgroundColor: AppColors.primary,
      title: Text(title),
      actions: combinedActions.isNotEmpty ? combinedActions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}