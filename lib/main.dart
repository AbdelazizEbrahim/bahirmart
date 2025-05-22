import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/core/models/user_model.dart';
import 'package:bahirmart/core/navigation/app_router.dart';
import 'package:bahirmart/theme/app_theme.dart';
import 'package:bahirmart/core/services/cart_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await _requestLocationPermission();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  User? user;

  if (token != null && token.isNotEmpty) {
    try {
      final baseUrl = dotenv.env['BASE_URL'];
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        user = User(
          id: data['_id'],
          fullName: data['fullName'] ?? 'User',
          email: data['email'],
          role: data['role'],
          image: data['image'] ?? 'https://picsum.photos/50/50?random=1',
          password: '',
          isBanned: data['isBanned'] ?? false,
          isEmailVerified: data['isEmailVerified'] ?? true,
          isDeleted: data['isDeleted'] ?? false,
        );

        // Store updated email in case it changed
        await prefs.setString('user_email', data['email']);
      } else {
        print('Failed to fetch user info: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
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

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void updateUser({
    String? id,
    String? fullName,
    String? email,
    String? password,
    String? role,
    String? image,
    bool? isBanned,
    DateTime? bannedAt,
    String? bannedBy,
    bool? isEmailVerified,
    String? phoneNumber,
    bool? isDeleted,
    DateTime? trashDate,
    String? approvalStatus,
    String? approvedBy,
    String? otp,
    DateTime? otpExpires,
  }) {
    if (_user != null) {
      _user = User(
        id: id ?? _user!.id,
        fullName: fullName ?? _user!.fullName,
        email: email ?? _user!.email,
        password: password ?? _user!.password,
        role: role ?? _user!.role,
        image: image ?? _user!.image,
        isBanned: isBanned ?? _user!.isBanned,
        bannedBy: bannedBy ?? _user!.bannedBy,
        isEmailVerified: isEmailVerified ?? _user!.isEmailVerified,
        phoneNumber: phoneNumber ?? _user!.phoneNumber,
        isDeleted: isDeleted ?? _user!.isDeleted,
        trashDate: trashDate ?? _user!.trashDate,
        otp: otp ?? _user!.otp,
        otpExpires: otpExpires ?? _user!.otpExpires,
      );
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
