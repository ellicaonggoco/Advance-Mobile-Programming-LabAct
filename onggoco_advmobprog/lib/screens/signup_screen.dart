import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// ==============================================================
// ENHANCEMENT 2: User interface for signup_screen requiring:
// - fName, lName, age, contactNo, username, emailAddress, password (with validation)
// Powered by FirebaseAuth createAccount (PDF Page 18)
// ==============================================================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fNameController = TextEditingController();
  final TextEditingController _lNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fNameController.dispose();
    _lNameController.dispose();
    _ageController.dispose();
    _contactNoController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName =
        '${_fNameController.text.trim()} ${_lNameController.text.trim()}'.trim();

    try {
      await userService.value.createAccount(
        email: email,
        password: password,
        displayName:
            fullName.isNotEmpty ? fullName : _usernameController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Account successfully created! You may now log in.'),
          backgroundColor: Colors.green.shade700,
        ),
      );

      Navigator.pushReplacementNamed(context, '/signin');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Registration Failed: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}'),
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
      appBar: AppBar(
        title: CustomText(
          text: 'Sign Up',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Title
                  CustomText(
                    text: 'Create an Account',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6.h),
                  CustomText(
                    text: 'Register with Firebase Authentication',
                    fontSize: 13.sp,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),

                  // 1. First Name (fName)
                  TextFormField(
                    controller: _fNameController,
                    decoration: _buildInputDecoration(
                      label: 'First Name',
                      isDark: isDark,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // 2. Last Name (lName)
                  TextFormField(
                    controller: _lNameController,
                    decoration: _buildInputDecoration(
                      label: 'Last Name',
                      isDark: isDark,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Row: Age and Contact No
                  Row(
                    children: [
                      // 3. Age
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: _buildInputDecoration(
                            label: 'Age',
                            isDark: isDark,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Age required';
                            }
                            final age = int.tryParse(val.trim());
                            if (age == null || age <= 0 || age > 120) {
                              return 'Invalid age';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // 4. Contact Number (contactNo)
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _contactNoController,
                          keyboardType: TextInputType.phone,
                          decoration: _buildInputDecoration(
                            label: 'Contact No',
                            isDark: isDark,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Contact No required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // 5. Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: _buildInputDecoration(
                      label: 'Username',
                      isDark: isDark,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Username is required';
                      }
                      if (val.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // 6. Email Address (emailAddress)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration(
                      label: 'Email Address',
                      isDark: isDark,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email address is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(val.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // 7. Password (with validation)
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
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Password is required';
                      }
                      if (val.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _buildInputDecoration(
                      label: 'Confirm Password',
                      isDark: isDark,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 22.h),

                  // Register Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
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
                            text: 'Register Account',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                  ),
                  SizedBox(height: 14.h),

                  // Link to Sign In
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        text: 'Already have an account? ',
                        fontSize: 13.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/signin');
                        },
                        child: CustomText(
                          text: 'Log In',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF354593),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
