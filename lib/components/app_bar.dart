import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      if (userProvider.user != null) ...[
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
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundImage: (userProvider.user!.image?.isNotEmpty ?? false)
                ? NetworkImage(userProvider.user!.image!)
                : null,
          ),
          onSelected: (value) async {
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
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                await prefs.remove('user_email');

                Provider.of<UserProvider>(context, listen: false).setUser(null);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
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
      ] else ...[
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signin');
          },
          child: const Text(
            'Sign In',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text(
            'Sign Up',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ];

    // Combine custom actions with default actions
    final List<Widget> combinedActions = [
      if (actions != null) ...actions!, // Spread custom actions if not null
      ...defaultActions, // Spread default actions
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
