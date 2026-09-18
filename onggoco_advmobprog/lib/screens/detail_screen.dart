import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/custom_text.dart';

// --------------------------------------------------------------
// ENHANCEMENT 1 & 2: Detail Screen utilized by both ProductScreen & CartScreen
// --------------------------------------------------------------
class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isAddingToCart = false;

  // --------------------------------------------------------------
  // ENHANCEMENT 3: Add to cart by passing product values (https://dummyjson.com/carts/add)
  // Updates CartProvider for live UI reactivity across Home and Cart!
  // --------------------------------------------------------------
  Future<void> _handleAddToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Add to shared CartProvider for real-time app update
      await Provider.of<CartProvider>(context, listen: false)
          .addToCart(widget.product, quantity: 1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: CustomText(
              text: 'Added "${widget.product.title}" to cart!',
              color: Colors.white,
              fontSize: 13.sp,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: CustomText(
              text: 'Failed to add to cart: $e',
              color: Colors.white,
              fontSize: 13.sp,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: 'Total Price',
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                  CustomText(
                    text: '\$${product.price.toStringAsFixed(2)}',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isAddingToCart ? null : _handleAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: _isAddingToCart
                      ? SizedBox(
                          width: 18.w,
                          height: 18.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.shopping_cart),
                  label: CustomText(
                    text: _isAddingToCart ? 'Adding...' : 'Add to Cart',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 250.h,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Image.network(
                product.thumbnail,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported,
                  size: 50.sp,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomText(
                          text: product.title,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CustomText(
                        text: '\$${product.price.toStringAsFixed(2)}',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Rating & Brand
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18.sp),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: '${product.rating} / 5.0',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(width: 16.w),
                      if (product.brand.isNotEmpty)
                        Chip(
                          label: CustomText(
                            text: product.brand,
                            fontSize: 12.sp,
                          ),
                        ),
                      SizedBox(width: 8.w),
                      Chip(
                        label: CustomText(
                          text: product.category.toUpperCase(),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Description
                  CustomText(
                    text: 'Description',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 6.h),
                  CustomText(
                    text: product.description,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 16.h),
                  // Product details card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        children: [
                          _buildDetailRow('Stock', '${product.stock} available'),
                          const Divider(),
                          _buildDetailRow('Warranty', product.warrantyInformation),
                          const Divider(),
                          _buildDetailRow('Shipping', product.shippingInformation),
                          const Divider(),
                          _buildDetailRow('Return Policy', product.returnPolicy),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Reviews Section
                  if (product.reviews.isNotEmpty) ...[
                    CustomText(
                      text: 'Customer Reviews (${product.reviews.length})',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(height: 8.h),
                    ...product.reviews.map(
                      (review) => Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: review.reviewerName,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: CustomText(
                            text: review.comment,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: title,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          CustomText(
            text: value.isEmpty ? 'N/A' : value,
            fontSize: 13.sp,
          ),
        ],
      ),
    );
  }
}

// Typedef alias for backward compatibility with product_detail_screen
typedef ProductDetailScreen = DetailScreen;
