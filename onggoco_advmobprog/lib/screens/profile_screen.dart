import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

// profile screen to, kusa nag-iiba itsura depende kung firebase o dummyjson user
// pag firebase may extra buttons para mag-update username, change password, tsaka delete account

class ProfileScreen extends StatefulWidget {
  final dynamic initialUser;
  final Map<String, dynamic>? initialUserData;
  final bool isStandalone;

  const ProfileScreen({
    super.key,
    this.initialUser,
    this.initialUserData,
    this.isStandalone = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  Map<String, dynamic>? _userData;
  String _loginType = 'dummyjson';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // check natin kung anong login type tapos load yung user info
  Future<void> _loadUserData() async {
    try {
      final type = await _userService.getLoginType();
      final data = await _userService.getUserData();

      if (mounted) {
        setState(() {
          _loginType = type;
          _userData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // pop-up para makapag-palit ng username
  void _showUpdateUsernameDialog() {
    final TextEditingController usernameController = TextEditingController(
      text: _userData?['username']?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const CustomText(
          text: 'Update Username',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomText(
                text: 'Enter your new display username:',
                fontSize: 13,
                color: Colors.grey,
              ),
              SizedBox(height: 14.h),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  if (val.trim().length < 3) {
                    return 'Minimum 3 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF354593),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newUsername = usernameController.text.trim();
                Navigator.pop(ctx);
                try {
                  await _userService.updateUsername(username: newUsername);
                  await _loadUserData();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Username updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update username: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // pop-up para makapag-change pass, hingi muna old pass
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const CustomText(
          text: 'Change Password',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Current password required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.h),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'New password required';
                  }
                  if (val.length < 6) {
                    return 'Minimum 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF354593),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final currentPwd = currentPasswordController.text;
                final newPwd = newPasswordController.text;
                final email = _userData?['email']?.toString() ?? '';
                Navigator.pop(ctx);
                try {
                  await _userService.resetPasswordFromCurrentPassword(
                    currentPassword: currentPwd,
                    newPassword: newPwd,
                    email: email,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password changed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to change password: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  // pop-up para sa delete account, hingi password para sure
  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const CustomText(
          text: 'Delete Account',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                text:
                    'This action is irreversible. Please enter your password to confirm account deletion:',
                fontSize: 13,
                color: Colors.grey,
              ),
              SizedBox(height: 14.h),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Password is required to delete account';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final pwd = passwordController.text;
                final email = _userData?['email']?.toString() ?? '';
                Navigator.pop(ctx);
                try {
                  await _userService.deleteAccount(
                    email: email,
                    password: pwd,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account permanently deleted.'),
                      backgroundColor: Colors.black87,
                    ),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/signin',
                    (route) => false,
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete account: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  // logout dialog sabay lipat pabalik sign in screen
  Future<void> _handleLogout() async {
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

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _userData ?? {};
    final isFirebase = _loginType == 'firebase';

    final displayName = isFirebase
        ? ((data['firstName'] != null &&
                data['firstName'].toString().isNotEmpty)
            ? data['firstName'].toString()
            : (data['username'] ?? 'User'))
        : ((data['firstName'] != null &&
                data['firstName'].toString().isNotEmpty)
            ? '${data['firstName']} ${data['lastName'] ?? ''}'.trim()
            : (data['username'] ?? 'User'));
    final username = data['username']?.toString() ?? 'user';
    final email = data['email']?.toString() ?? 'No email';
    final gender = data['gender']?.toString() ?? 'N/A';
    final userId = (data['id'] != null && data['id'] != 0)
        ? '#${data['id']}'
        : (data['token'] != null && data['token'].toString().isNotEmpty
            ? '${data['token'].toString().substring(0, (data['token'].toString().length > 10 ? 10 : data['token'].toString().length))}...'
            : '#1');
    final imageUrl = data['image']?.toString() ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Profile Header Card
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
                // Avatar
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
                        : const Icon(
                            Icons.person,
                            size: 48,
                            color: Color(0xFF354593),
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
                // Username handle
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

          // User Information Details Card (depends on loginType)
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
                if (!isFirebase) ...[
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
                ],
                _buildInfoRow(
                  icon: Icons.badge_outlined,
                  label: isFirebase ? 'Account ID' : 'User ID',
                  value: userId,
                  context: context,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Firebase Account Management Actions (Enhancement 3)
          if (isFirebase) ...[
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
                  ListTile(
                    leading: const Icon(Icons.edit, color: Color(0xFF354593)),
                    title: const CustomText(
                      text: 'Update Username',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: const CustomText(
                      text: 'Change your Firebase display name',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showUpdateUsernameDialog,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.lock_reset, color: Color(0xFFF5A623)),
                    title: const CustomText(
                      text: 'Change Password',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: const CustomText(
                      text: 'Update your Firebase login password',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16.w,
                    endIndent: 16.w,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.delete_outline, color: Colors.red),
                    title: const CustomText(
                      text: 'Delete Account',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                    subtitle: const CustomText(
                      text: 'Permanently remove Firebase account',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showDeleteAccountDialog,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Log Out Button
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

  @override
  Widget build(BuildContext context) {
    if (widget.isStandalone) {
      return Scaffold(
        appBar: AppBar(
          title: const CustomText(
            text: 'Profile',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        body: _buildContent(context),
      );
    }
    return _buildContent(context);
  }
}
