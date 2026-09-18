import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// ==============================================================
// ENHANCEMENT 3: Using the user_service create your own user.dart
// (model) implementing it on this project and rendering the data
// on the profile_screen creating UI on it.
// ==============================================================

class ProfileScreen extends StatefulWidget {
  final User? initialUser;
  const ProfileScreen({super.key, this.initialUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialUser != null) {
      _user = widget.initialUser;
      _isLoading = false;
    } else {
      _loadUserData();
    }
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 3: Retrieve saved user model from UserService
  // --------------------------------------------------------------
  Future<void> _loadUserData() async {
    try {
      final user = await _userService.getUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 3: Logout handler clearing SharedPreferences
  // --------------------------------------------------------------
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const CustomText(
          text: 'Confirm Logout',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: const CustomText(
          text: 'Are you sure you want to log out of your account?',
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (route) => false,
      );
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: const Color(0xFFF5A623),
          ),
          SizedBox(width: 12.w),
          CustomText(
            text: label,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF334155),
          ),
          const Spacer(),
          Flexible(
            child: CustomText(
              text: value.isNotEmpty ? value : 'N/A',
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = _user;
    final displayName = (user != null && user.firstName.isNotEmpty)
        ? user.fullName
        : 'Emily Johnson';
    final username =
        (user != null && user.username.isNotEmpty) ? user.username : 'emilys';
    final email = (user != null && user.email.isNotEmpty)
        ? user.email
        : 'emily.johnson@x.dummyjson.com';
    final gender =
        (user != null && user.gender.isNotEmpty) ? user.gender : 'female';
    final userId = (user != null && user.id > 0) ? '${user.id}' : '1';
    final imageUrl = user?.image ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header Card matching Sample Output
          Container(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // User Avatar
                Container(
                  width: 76.w,
                  height: 76.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFF354593),
                            ),
                          )
                        : Image.network(
                            'https://dummyjson.com/icon/emilys/128',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFF354593),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 12.h),
                // Full Name
                CustomText(
                  text: displayName,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                SizedBox(height: 4.h),
                // Username handle in gold/yellow
                CustomText(
                  text: '@$username',
                  fontSize: 13.sp,
                  color: const Color(0xFFF5A623),
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // User Information Details Card matching Sample Output
          Container(
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  value: email,
                  context: context,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                _buildInfoRow(
                  icon: Icons.people_outline,
                  label: 'Gender',
                  value: gender,
                  context: context,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                ),
                _buildInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'User ID',
                  value: '#$userId',
                  context: context,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Log Out Button matching Sample Output
          ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            label: CustomText(
              text: 'Log Out',
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5757),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
