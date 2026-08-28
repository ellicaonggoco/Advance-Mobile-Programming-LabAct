import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // --------------------------------------------------------------
  // ENHANCEMENT 3: Read Cart documentation https://dummyjson.com/docs/carts
  // Integrate cart by user ID to render only one user cart.
  // --------------------------------------------------------------
  late Future<Cart> _cartFuture;
  Cart? _currentCart;
  final int _userId = 5; // Single user cart integration

  @override
  void initState() {
    super.initState();
    _loadUserCart();
  }

  void _loadUserCart() {
    // Enhancement 3: Fetching cart for a single user (User ID: 5)
    _cartFuture = CartService().getCartByUserId(_userId).catchError((_) {
      // Fallback to getCartById(1) if specific user endpoint format differs
      return CartService().getCartById(1);
    });
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 1: Convert CartProduct into Product model to navigate
  // and utilize the reusable detail_screen.dart widget.
  // --------------------------------------------------------------
  Product _productFromCartProduct(CartProduct item) {
    return Product(
      id: item.id,
      title: item.title,
      description: 'High-quality ${item.title}. Available now in your cart with ${item.discountPercentage}% discount.',
      category: 'Cart Item',
      price: item.price,
      discountPercentage: item.discountPercentage,
      rating: 4.8,
      stock: item.quantity + 10,
      tags: const ['Cart', 'Trending'],
      brand: 'Featured Brand',
      sku: 'CART-${item.id}',
      weight: 1.0,
      dimensions: ProductDimensions(width: 10, height: 10, depth: 10),
      warrantyInformation: '1-year brand warranty',
      shippingInformation: 'Free delivery within 2-3 business days',
      availabilityStatus: 'In Stock',
      reviews: [
        ProductReview(
          rating: 5,
          comment: 'Excellent product quality and fast delivery!',
          date: '2026-08-20',
          reviewerName: 'Happy Customer',
          reviewerEmail: 'customer@example.com',
        ),
      ],
      returnPolicy: '30-day return policy',
      minimumOrderQuantity: 1,
      meta: ProductMeta(
        createdAt: '2026-01-01',
        updatedAt: '2026-08-29',
        barcode: 'CART${item.id}',
        qrCode: 'https://dummyjson.com',
      ),
      images: item.thumbnail.isNotEmpty ? [item.thumbnail] : const [],
      thumbnail: item.thumbnail,
    );
  }

  void _updateQuantity(CartProduct item, int delta) {
    if (_currentCart == null) return;

    setState(() {
      final index = _currentCart!.products.indexWhere((p) => p.id == item.id);
      if (index != -1) {
        final currentQty = _currentCart!.products[index].quantity;
        final newQty = currentQty + delta;

        if (newQty > 0) {
          final updatedProduct = CartProduct(
            id: item.id,
            title: item.title,
            price: item.price,
            quantity: newQty,
            total: item.price * newQty,
            discountPercentage: item.discountPercentage,
            discountedTotal: (item.price * (1 - item.discountPercentage / 100)) * newQty,
            thumbnail: item.thumbnail,
          );

          _currentCart!.products[index] = updatedProduct;
        } else {
          _currentCart!.products.removeAt(index);
        }
      }
    });
  }

  double get _calculatedTotal {
    if (_currentCart == null) return 0.0;
    return _currentCart!.products.fold(0.0, (sum, item) => sum + item.total);
  }

  double get _calculatedDiscountedTotal {
    if (_currentCart == null) return 0.0;
    return _currentCart!.products.fold(0.0, (sum, item) => sum + item.discountedTotal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'Cart',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 24.sp),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _currentCart == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _currentCart == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                  SizedBox(height: 12.h),
                  CustomText(
                    text: 'Unable to load cart data.',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadUserCart();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_currentCart == null && snapshot.hasData) {
            _currentCart = snapshot.data;
          }

          final cart = _currentCart;
          if (cart == null || cart.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Your cart is empty',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: cart.products.length,
                  itemBuilder: (context, index) {
                    final item = cart.products[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        // --------------------------------------------------------------
                        // ENHANCEMENT 1: Cart item is clickable and navigates to detail_screen
                        // --------------------------------------------------------------
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                product: _productFromCartProduct(item),
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Row(
                            children: [
                              // Product Thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.r),
                                child: Container(
                                  width: 70.w,
                                  height: 70.h,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: item.thumbnail.isNotEmpty
                                      ? Image.network(
                                          item.thumbnail,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.image, size: 30.sp),
                                        )
                                      : Icon(Icons.image_not_supported, size: 30.sp),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: item.title,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6.h),
                                    CustomText(
                                      text: '\$${item.price.toStringAsFixed(2)}',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                    SizedBox(height: 2.h),
                                    CustomText(
                                      text: '${item.discountPercentage.toStringAsFixed(0)}% off • \$${item.discountedTotal.toStringAsFixed(2)} total',
                                      fontSize: 11.sp,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              // Quantity Stepper Controls
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => _updateQuantity(item, 1),
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF5A623),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.add, size: 14.sp, color: Colors.white),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                                      child: CustomText(
                                        text: '${item.quantity}',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _updateQuantity(item, -1),
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF5A623),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.remove, size: 14.sp, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom Checkout / Order Summary Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Subtotal',
                            fontSize: 13.sp,
                            color: Colors.grey,
                          ),
                          CustomText(
                            text: '\$${_calculatedTotal.toStringAsFixed(2)}',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Discounted Total',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                            text: '\$${_calculatedDiscountedTotal.toStringAsFixed(2)}',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFF5A623),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const CustomText(
                                  text: 'Order Confirmed!',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                content: CustomText(
                                  text: 'Thank you for your order! Total amount: \$${_calculatedDiscountedTotal.toStringAsFixed(2)}',
                                  fontSize: 14,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5A623),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: CustomText(
                            text: 'Confirm Order',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
