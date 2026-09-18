import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// ==============================================================
// ENHANCEMENT 1: Make your own UI for the splash_screen
// implementing the persistent authentication.
// ==============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 1: Check authentication persistence using UserService.
  // If logged in, pass user credentials to /home; otherwise redirect to /signin.
  // --------------------------------------------------------------
  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await _userService.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      final userData = await _userService.getUserData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: userData,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // National University Logo (transparent background matching Sample Output)
              Image.asset(
                'assets/images/nu_logo.png',
                width: 125.w,
                height: 125.w,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 24.h),
              // Brand text matching Sample Output: NUBD Exchange
              CustomText(
                text: 'NUBD Exchange',
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              SizedBox(height: 32.h),
              // Gold progress indicator matching Sample Output
              SizedBox(
                width: 26.w,
                height: 26.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5A623)),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
