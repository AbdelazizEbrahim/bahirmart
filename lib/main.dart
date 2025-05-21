import 'package:bahirmart/components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/core/models/user_model.dart';
import 'package:bahirmart/core/navigation/app_router.dart';
import 'package:bahirmart/theme/app_theme.dart';
import 'package:bahirmart/core/services/cart_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await _requestLocationPermission();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final email = prefs.getString('user_email');

  User? user;
  if (token != null && email != null) {
    user = User(
      id: 'from_token', // Replace with actual user ID if needed
      fullName: 'Loaded User',
      email: email,
      password: '', // Not stored locally
      role: 'customer',
      image: 'https://picsum.photos/50/50?random=1',
      isBanned: false,
      isEmailVerified: true,
      isDeleted: false,
      approvalStatus: 'approved',
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..setUser(user)),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: const BahirMartApp(),
    ),
  );
}

Future<void> _requestLocationPermission() async {
  final status = await Permission.location.request();
  if (status.isDenied) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'BahirMart needs access to your location to show you nearby products and merchants. '
            'Please enable location access in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    });
  }
}

class BahirMartApp extends StatelessWidget {
  const BahirMartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BahirMart',
      theme: AppTheme.theme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.generateRoute,
      navigatorKey: navigatorKey,
      initialRoute: '/',
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

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: BahirMartAppBar(title: 'BahirMart'),
      body: Center(
        child: Text('Welcome to BahirMart'),
      ),
    );
  }
}
