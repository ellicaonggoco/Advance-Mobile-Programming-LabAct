// packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// screens
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

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
            initialRoute: '/home',
            routes: {
              // ENHANCEMENT 1: Cart route for loading the carts API screen
              '/cart': (context) => const CartScreen(isStandalone: true),
              // ENHANCEMENT 3: Route to settings page
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}