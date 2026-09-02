import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// models
import '../models/product.dart';

// providers
import '../providers/cart_provider.dart';

// services
import '../services/product_service.dart';

// widgets
import '../widgets/custom_text.dart';

// screens
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Future<List<Product>> _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().getAllProducts();
  }

  // -------------------------------------------------------------- 
  // -------------------------------------------------------------- 
  // ENHANCEMENT 1: Search bar above the product/article list
  // -------------------------------------------------------------- 
  // -------------------------------------------------------------- 
  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((product) {
          final titleMatch = product.title.toLowerCase().contains(query.toLowerCase());
          final categoryMatch = product.category.toLowerCase().contains(query.toLowerCase());
          final brandMatch = product.brand.toLowerCase().contains(query.toLowerCase());
          return titleMatch || categoryMatch || brandMatch;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            // ENHANCEMENT 1: Search bar UI widget
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterProducts('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 40.sp, color: Colors.grey),
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'Unable to load products.',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 8.h),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _productsFuture =
                                    ProductService().getAllProducts();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_allProducts.isEmpty && snapshot.hasData) {
                  _allProducts = snapshot.data!;
                  _filteredProducts = _allProducts;
                }

                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),
                      child: CustomText(
                        text: 'No products found.',
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: 0.75,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return GestureDetector(
                     // -------------------------------------------------------------- 
                     // ENHANCEMENT 2: Open product detail page when card is tapped
                     // -------------------------------------------------------------- 
                     onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                product.thumbnail,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image, size: 24.sp),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: product.title,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        text:
                                            '\$${product.price.toStringAsFixed(2)}',
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          context
                                              .read<CartProvider>()
                                              .addToCart(product);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor:
                                                  Colors.green.shade700,
                                              content: CustomText(
                                                text:
                                                    'Added "${product.title}" to cart!',
                                                color: Colors.white,
                                                fontSize: 13.sp,
                                              ),
                                              duration:
                                                  const Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: Container(
                                          padding: EdgeInsets.all(5.r),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFF5A623),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.add_shopping_cart,
                                            size: 14.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
