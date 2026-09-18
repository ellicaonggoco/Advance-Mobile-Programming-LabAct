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
              // National University Logo
              Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF354593).withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(12.w),
                child: Image.asset(
                  'assets/images/nu_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/nuicon.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.school,
                          size: 72.sp,
                          color: const Color(0xFF354593),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),
              // Brand text matching Sample Output: NUBD Exchange
              CustomText(
                text: 'NUBD Exchange',
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
              SizedBox(height: 6.h),
              CustomText(
                text: 'National University E-Commerce Portal',
                fontSize: 12.sp,
                color: Colors.grey.shade500,
                letterSpacing: 0.2,
              ),
              const Spacer(flex: 2),
              // Loading indicator
              SizedBox(
                width: 28.w,
                height: 28.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF354593)),
                ),
              ),
              SizedBox(height: 12.h),
              CustomText(
                text: 'Checking authentication...',
                fontSize: 12.sp,
                color: Colors.grey.shade400,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
