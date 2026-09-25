// packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// screens
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';

// providers
import 'providers/cart_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) async {
      try {
        await dotenv.load(fileName: 'assets/.env');
      } catch (e) {
        // Fallback if .env is missing during tests
      }
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint('Firebase init error: $e');
      }
      runApp(const OnggocoAdvMobProg());
    },
  );
}

class OnggocoAdvMobProg extends StatelessWidget {
  const OnggocoAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()..loadCart()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (build, child) {
          final themeModel = build.watch<ThemeProvider>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeModel.lightTheme,
            darkTheme: themeModel.darkTheme,
            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
            title: 'E-Commerce App',
            initialRoute: '/splash',
            routes: {
              // ENHANCEMENT 1: Splash screen with persistent authentication
              '/splash': (context) => const SplashScreen(),
              // ENHANCEMENT 2: Sign-in screen with login & auth logic
              '/signin': (context) => const SigninScreen(),
              // ENHANCEMENT 2: Sign-up screen with Firebase Auth logic
              '/signup': (context) => const SignupScreen(),
              // Main Home Catalog & Navigation
              '/home': (context) => const HomeScreen(),
              // Standalone Cart route
              '/cart': (context) => const CartScreen(isStandalone: true),
              // Settings page
              '/settings': (context) => const SettingsScreen(),
              // ENHANCEMENT 3: Standalone Profile page
              '/profile': (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}