import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'cart_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';
import '../models/user.dart';
import '../providers/cart_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && _currentUser == null) {
      final user = User.fromJson(args);
      setState(() {
        _currentUser = user;
      });
      if (user.id > 0) {
        context.read<CartProvider>().loadCart(user.id);
      }
    }
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 3: Retrieve saved user data and render cart by userId
  // --------------------------------------------------------------
  Future<void> _initUserData() async {
    try {
      final user = await UserService().getUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        if (user.id > 0) {
          context.read<CartProvider>().loadCart(user.id);
        }
      }
    } catch (_) {}
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 2: Make the chat bottom navigation as FloatingActionButton.
  // When in the cart_screen the FloatingActionButton must be hidden.
  // --------------------------------------------------------------
  Widget? _buildFloatingActionButton() {
    // If currently on Cart screen (index 1), hide the FloatingActionButton
    if (_selectedIndex == 1) {
      return null;
    }

    return FloatingActionButton(
      backgroundColor: const Color(0xFFF5A623),
      foregroundColor: Colors.white,
      tooltip: 'Chat Support',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          builder: (ctx) => Container(
            padding: EdgeInsets.all(20.r),
            height: 300.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: const Color(0xFFF5A623), size: 24.sp),
                    SizedBox(width: 8.w),
                    CustomText(
                      text: 'Customer Support Chat',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Hello! How can we assist you with your shopping experience today?',
                  fontSize: 14.sp,
                ),
                const Spacer(),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFFF5A623)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message sent to support!')),
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: const Icon(Icons.chat),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          backgroundColor: (_selectedIndex == 1 || _selectedIndex == 2)
              ? const Color(0xFF354593)
              : null,
          title: _selectedIndex == 0
              ? Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  scale: 11.5.sp,
                  errorBuilder: (context, error, stackTrace) => CustomText(
                    text: 'E-Commerce Shopping App',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : CustomText(
                  text: _selectedIndex == 1
                      ? 'Cart'
                      : (_currentUser != null && _currentUser!.firstName.isNotEmpty
                          ? _currentUser!.firstName
                          : 'Emily'),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: (_selectedIndex == 1 || _selectedIndex == 2)
                      ? Colors.white
                      : null,
                ),
          actions: [
            // Cart icon only shown on Shop catalog tab (tab 0)
            if (_selectedIndex == 0)
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, size: 24.sp),
                onPressed: () {
                  _onItemTapped(1);
                },
              ),
            // Access settings page from the top-right icon
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 24.sp,
                color: (_selectedIndex == 1 || _selectedIndex == 2)
                    ? Colors.white
                    : null,
              ),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
          children: [
            // Tab 0: Product catalog screen
            const ProductScreen(),
            // Tab 1: Cart Screen (Enhancement 1 & 3)
            const CartScreen(isStandalone: false),
            // Tab 2: Profile Screen (Enhancement 3)
            ProfileScreen(initialUser: _currentUser),
          ],
        ),
        // --------------------------------------------------------------
        // ENHANCEMENT 2: Chat as FloatingActionButton, hidden when on cart_screen
        // --------------------------------------------------------------
        floatingActionButton: _buildFloatingActionButton(),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: const Color(0xFF354593),
          unselectedItemColor: Colors.grey.shade600,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }
}
