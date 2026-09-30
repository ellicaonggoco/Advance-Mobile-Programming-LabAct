import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? _currentUserEmail;
  String? _currentUserId;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
    _chatService.seedInitialUsersIfEmpty();
  }

  Future<void> _loadCurrentUserData() async {
    final currentUser = userService.value.currentUser;
    final userData = await userService.value.getUserData();
    if (mounted) {
      setState(() {
        _currentUserEmail = currentUser?.email ?? userData['email']?.toString();
        _currentUserId = currentUser?.uid ?? userData['token']?.toString();
      });
    }

    if (currentUser != null) {
      final name = currentUser.displayName ??
          (userData['firstName'] != null && userData['firstName'].toString().isNotEmpty
              ? userData['firstName'].toString()
              : currentUser.email?.split('@').first);
      await _chatService.saveUserRecord(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        firstName: name,
      );
    }
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 16.h),
          // Enhancement 2: Search bar for filtering users by name or email
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchChatController,
              textInputAction: TextInputAction.search,
              onChanged: (val) {
                setState(() {
                  _searchText = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search chat...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchChatController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchChatController.clear();
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // StreamBuilder for real-time users list
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _chatService.getUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 300.h,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  height: 300.h,
                  child: const Center(
                    child: CustomText(text: 'Error loading users'),
                  ),
                );
              }

              final allUsers = snapshot.data ?? [];

              // Enhancement 1: Exclude logged-in user & Enhancement 2: Search filter
              final users = allUsers.where((u) {
                final email = (u['email'] ?? '').toString();
                final uid = (u['uid'] ?? '').toString();

                final isMe = (uid.isNotEmpty && uid == _currentUserId) ||
                    (_currentUserEmail != null &&
                        _currentUserEmail!.isNotEmpty &&
                        email.toLowerCase() ==
                            _currentUserEmail!.toLowerCase());
                if (isMe) return false;

                if (_searchText.isNotEmpty) {
                  final name = (u['firstName'] ?? '').toString().toLowerCase();
                  final query = _searchText.toLowerCase();
                  return name.contains(query) ||
                      email.toLowerCase().contains(query);
                }
                return true;
              }).toList();

              if (users.isEmpty) {
                return SizedBox(
                  height: 300.h,
                  child: Center(
                    child: CustomText(
                      text: _searchText.isNotEmpty
                          ? 'No users match "$_searchText"'
                          : 'No other users found',
                      fontSize: 15.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final displayName = (user['firstName'] != null &&
                          user['firstName'].toString().isNotEmpty)
                      ? user['firstName'].toString()
                      : 'Unknown User';
                  final email = user['email']?.toString() ?? 'No email';

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 6.h),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 4.h,
                      ),
                      leading: CircleAvatar(
                        radius: 22.r,
                        backgroundColor: const Color(0xFF354593),
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chat_bubble_outline,
                        color: Color(0xFF354593),
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              currentUserEmail: _currentUserEmail ?? '',
                              currentUserId: _currentUserId ?? '',
                              tappedUser: user,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
