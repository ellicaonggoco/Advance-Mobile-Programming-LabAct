import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// signin screen: may dalawang login option (DummyJSON at Firebase Auth)
// required to sa enhancement 2 para may toggle kung san magla-login si user

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // hiwalay controllers para sa username (dummyjson) at email (firebase)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 0: DummyJSON, 1: Firebase Auth
  int _selectedAuthIndex = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // pag pinindot yung log in button, check natin kung anong tab yung active
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> responseData;

      if (_selectedAuthIndex == 0) {
        // dummyjson login (username at pass lang tulad nung emilys / emilyspass)
        responseData = await userService.value.loginUser(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // firebase login gamit email at password
        await userService.value.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        responseData = await userService.value.getUserData();
      }

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // lipat na sa home screen tapos pasa yung user data
      Navigator.pushReplacementNamed(context, '/home', arguments: responseData);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      String errorMessage =
          e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
      if (errorMessage.startsWith('Exception:')) {
        errorMessage = errorMessage.replaceFirst('Exception:', '').trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $errorMessage'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(
          color: Color(0xFF354593),
          width: 1.5,
        ),
      ),
    );
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
                  // Header logo at text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/nu_logo.png',
                        height: 38.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(width: 10.w),
                      CustomText(
                        text: 'Welcome',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // dalawang option para sa login: DummyJSON vs Firebase Auth
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.all(4.r),
                    child: Row(
                      children: [
                        // Option 1: DummyJSON
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAuthIndex = 0;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: _selectedAuthIndex == 0
                                    ? const Color(0xFF354593)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: CustomText(
                                  text: 'DummyJSON',
                                  fontSize: 13.sp,
                                  fontWeight: _selectedAuthIndex == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedAuthIndex == 0
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Option 2: Firebase Auth
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAuthIndex = 1;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: _selectedAuthIndex == 1
                                    ? const Color(0xFF354593)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Center(
                                child: CustomText(
                                  text: 'Firebase Auth',
                                  fontSize: 13.sp,
                                  fontWeight: _selectedAuthIndex == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedAuthIndex == 1
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.grey.shade300
                                          : Colors.grey.shade700),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Fields na nagpapalit depende kung anong option pinili
                  if (_selectedAuthIndex == 0) ...[
                    // DummyJSON - Username ang kailangan
                    TextFormField(
                      controller: _usernameController,
                      decoration: _buildInputDecoration(
                        label: 'Username',
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (_selectedAuthIndex == 0 &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Pakilagay yung username mo';
                        }
                        return null;
                      },
                    ),
                  ] else ...[
                    // Firebase - Email address ang kailangan
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration(
                        label: 'Email Address',
                        isDark: isDark,
                      ),
                      validator: (value) {
                        if (_selectedAuthIndex == 1 &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Pakilagay yung email mo';
                        }
                        if (_selectedAuthIndex == 1 &&
                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value!.trim())) {
                          return 'Valid na email ilagay mo';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 16.h),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _buildInputDecoration(
                      label: 'Password',
                      isDark: isDark,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pakilagay yung password mo';
                      }
                      if (_selectedAuthIndex == 1 && value.length < 6) {
                        return 'At least 6 characters dapat password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Log In button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF354593),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFF354593).withValues(alpha: 0.6),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
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
                            text: 'Log In',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                  ),
                  SizedBox(height: 18.h),

                  // Sign Up Link (Enhancement 2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "Don't have an account? ",
                        fontSize: 13.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: CustomText(
                          text: 'Sign Up',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF354593),
                        ),
                      ),
                    ],
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
