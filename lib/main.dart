import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/core/models/user_model.dart';
import 'package:bahirmart/core/navigation/app_router.dart';
import 'package:bahirmart/theme/app_theme.dart';
import 'core/services/cart_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const BahirMartApp(),
    ),
  );
}

class BahirMartApp extends StatelessWidget {
  const BahirMartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BahirMart',
      theme: AppTheme.theme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class UserProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }
}