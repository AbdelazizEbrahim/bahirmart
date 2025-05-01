import 'package:bahirmart/components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/core/models/user_model.dart';
import 'package:bahirmart/core/navigation/app_router.dart';
import 'package:bahirmart/theme/app_theme.dart';
import 'package:bahirmart/core/services/cart_service.dart';
import 'package:bahirmart/pages/profile_page.dart';
import 'package:bahirmart/pages/sign_in_page.dart';
import 'package:bahirmart/pages/sign_up_page.dart';
import 'package:bahirmart/pages/verify_otp_page.dart';
import 'package:bahirmart/pages/landing_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final mockUser = User(
    id: 'user_1',
    fullName: 'Demo User',
    email: 'demo@bahirmart.com',
    password: 'demo123',
    role: 'customer',
    image: 'https://picsum.photos/50/50?random=1',
    isBanned: false,
    isEmailVerified: true,
    isDeleted: false,
    approvalStatus: 'approved',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => UserProvider()..setUser(mockUser)),
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
      navigatorKey: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      routes: {
        '/': (context) => const LandingPage(),
        '/signin': (context) => const SignInPage(),
        '/signup': (context) => const SignUpPage(),
        '/verify-otp': (context) => const VerifyOtpPage(),
        '/profile': (context) => const ProfilePage(),
      },
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
    return Scaffold(
      appBar: BahirMartAppBar(title: 'BahirMart'),
      body: const Center(
        child: Text('Welcome to BahirMart'),
      ),
    );
  }
}