import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// ==============================================================
// ENHANCEMENT 2: Make your own UI for the sign_screen
// implementing the user_service and the authentication logic above.
// ==============================================================

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController =
      TextEditingController(text: 'emilys');
  final TextEditingController _passwordController =
      TextEditingController(text: 'emilyspass');

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 2: Authentication logic invoking UserService
  // and persisting user session into SharedPreferences.
  // --------------------------------------------------------------
  void _login() async {
    UserService userService = UserService();
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final response = await userService.loginUser(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

        // Save user data to SharedPreferences
        await userService.saveUserData(response);

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacementNamed(context, '/home', arguments: response);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App / University Logo
                  Center(
                    child: Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF354593).withValues(alpha: 0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(10.w),
                      child: Image.asset(
                        'assets/images/nu_logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.school,
                            size: 48.sp,
                            color: const Color(0xFF354593),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  // Welcome Header matching Sample Output
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.waving_hand,
                        color: const Color(0xFFF5A623),
                        size: 24.sp,
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: 'Welcome',
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Center(
                    child: CustomText(
                      text: 'Sign in to access your NUBD Exchange account',
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'emilys',
                      prefixIcon: const Icon(Icons.person_outline),
                      filled: true,
                      fillColor: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF354593),
                          width: 1.8,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.grey.shade50,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF354593),
                          width: 1.8,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Log in button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF354593),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF354593).withValues(alpha: 0.6),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 1,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : CustomText(
                            text: 'Log in',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                  ),
                  SizedBox(height: 20.h),

                  // Hint Chip for DummyJSON testing
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5A623).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFFF5A623).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14.sp,
                            color: const Color(0xFFB47206),
                          ),
                          SizedBox(width: 6.w),
                          CustomText(
                            text: 'Demo credentials: emilys / emilyspass',
                            fontSize: 11.sp,
                            color: const Color(0xFFB47206),
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
