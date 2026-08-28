import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'cart_screen.dart';
import 'product_screen.dart';
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
                      : 'Profile',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
          actions: [
            // --------------------------------------------------------------
            // ENHANCEMENT 1: Cart button on navbar/top appbar
            // --------------------------------------------------------------
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined, size: 24.sp),
              onPressed: () {
                _onItemTapped(1);
              },
            ),
            // ENHANCEMENT 3: Access settings page from the top-right icon
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
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
            const CartScreen(),
            // Tab 2: Profile Screen
            Center(
              child: CustomText(
                text: 'Profile Page',
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        // --------------------------------------------------------------
        // ENHANCEMENT 2: Chat as FloatingActionButton, hidden when on cart_screen
        // --------------------------------------------------------------
        floatingActionButton: _buildFloatingActionButton(),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
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
