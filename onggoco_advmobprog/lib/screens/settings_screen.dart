import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// ==============================================================
// ENHANCEMENT 3: Settings Screen (Page 18 ng PDF)
// - Switch para sa Dark Mode / Light Mode
// - Logout button na nagki-clear ng session pabalik sa login
// ==============================================================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Handler para sa Logout sa loob ng settings
  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const CustomText(
          text: 'Confirm Logout',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: const CustomText(
          text: 'Are you sure you want to log out and return to the login screen?',
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
      await UserService().logout();
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signin',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Theme Switch
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SwitchListTile(
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                size: 24.sp,
              ),
              title: CustomText(
                text: themeProvider.isDark ? 'Dark Mode' : 'Light Mode',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              subtitle: CustomText(
                text: themeProvider.isDark
                    ? 'Enable or disable dark theme'
                    : 'Enable or disable light theme',
                fontSize: 12.sp,
              ),
              value: themeProvider.isDark,
              onChanged: (_) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          SizedBox(height: 12.h),

          // Logout Option (Enhancement 3)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: const Color(0xFFFF5757),
                size: 24.sp,
              ),
              title: CustomText(
                text: 'Log Out',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFF5757),
              ),
              subtitle: CustomText(
                text: 'Clears user session and returns to login',
                fontSize: 12.sp,
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _handleLogout(context),
            ),
          ),
        ],
      ),
    );
  }
}
