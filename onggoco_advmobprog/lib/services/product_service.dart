import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/product.dart';

class ProductService {
  static final List<Product> _featuredCartProducts = [
    Product(
      id: 162,
      title: 'Blue Frock',
      description:
          'Elegant Blue Frock made from high quality breathable fabrics, perfect for summer days and casual occasions.',
      category: 'womens-dresses',
      price: 29.99,
      discountPercentage: 12.13,
      rating: 4.8,
      stock: 15,
      tags: ['dress', 'clothing', 'fashion'],
      brand: 'Fashion Co.',
      sku: 'FRO-BLU-162',
      weight: 0.5,
      dimensions: ProductDimensions(width: 10, height: 20, depth: 5),
      warrantyInformation: '1 year warranty',
      shippingInformation: 'Ships in 1-2 days',
      availabilityStatus: 'In Stock',
      reviews: [],
      returnPolicy: '30 days return',
      minimumOrderQuantity: 1,
      meta: ProductMeta(
        createdAt: '',
        updatedAt: '',
        barcode: '',
        qrCode: '',
      ),
      images: [
        'https://cdn.dummyjson.com/product-images/tops/blue-frock/thumbnail.webp'
      ],
      thumbnail:
          'https://cdn.dummyjson.com/product-images/tops/blue-frock/thumbnail.webp',
    ),
    Product(
      id: 113,
      title: 'Generic Motorcycle',
      description:
          'A stylish and fuel-efficient generic motorcycle suitable for city commutes and weekend rides.',
      category: 'motorcycle',
      price: 3999.99,
      discountPercentage: 12.1,
      rating: 4.9,
      stock: 8,
      tags: ['motorcycle', 'vehicle', 'transport'],
      brand: 'SpeedMoto',
      sku: 'MOT-GEN-113',
      weight: 150.0,
      dimensions: ProductDimensions(width: 80, height: 110, depth: 200),
      warrantyInformation: '3 year warranty',
      shippingInformation: 'Ships in 1 week',
      availabilityStatus: 'In Stock',
      reviews: [],
      returnPolicy: '14 days return',
      minimumOrderQuantity: 1,
      meta: ProductMeta(
        createdAt: '',
        updatedAt: '',
        barcode: '',
        qrCode: '',
      ),
      images: [
        'https://cdn.dummyjson.com/product-images/motorcycle/generic-motorcycle/thumbnail.webp'
      ],
      thumbnail:
          'https://cdn.dummyjson.com/product-images/motorcycle/generic-motorcycle/thumbnail.webp',
    ),
    Product(
      id: 122,
      title: 'iPhone 6',
      description:
          'Classic smartphone with Retina HD display, 8MP iSight camera, and Touch ID fingerprint sensor.',
      category: 'smartphones',
      price: 299.99,
      discountPercentage: 6.69,
      rating: 4.7,
      stock: 20,
      tags: ['smartphone', 'apple', 'ios'],
      brand: 'Apple',
      sku: 'PHO-IP6-122',
      weight: 0.129,
      dimensions: ProductDimensions(width: 6.7, height: 13.8, depth: 0.7),
      warrantyInformation: '1 year Apple warranty',
      shippingInformation: 'Ships overnight',
      availabilityStatus: 'In Stock',
      reviews: [],
      returnPolicy: '30 days return',
      minimumOrderQuantity: 1,
      meta: ProductMeta(
        createdAt: '',
        updatedAt: '',
        barcode: '',
        qrCode: '',
      ),
      images: [
        'https://cdn.dummyjson.com/product-images/smartphones/iphone-6/thumbnail.webp'
      ],
      thumbnail:
          'https://cdn.dummyjson.com/product-images/smartphones/iphone-6/thumbnail.webp',
    ),
    Product(
      id: 138,
      title: 'Baseball Ball',
      description:
          'Official standard size baseball with genuine leather cover and raised seams for superior grip.',
      category: 'sports-accessories',
      price: 8.99,
      discountPercentage: 1.71,
      rating: 4.6,
      stock: 50,
      tags: ['sports', 'baseball', 'equipment'],
      brand: 'Rawlings',
      sku: 'SPO-BAS-138',
      weight: 0.145,
      dimensions: ProductDimensions(width: 7.3, height: 7.3, depth: 7.3),
      warrantyInformation: '6 months warranty',
      shippingInformation: 'Ships in 1-2 days',
      availabilityStatus: 'In Stock',
      reviews: [],
      returnPolicy: '30 days return',
      minimumOrderQuantity: 1,
      meta: ProductMeta(
        createdAt: '',
        updatedAt: '',
        barcode: '',
        qrCode: '',
      ),
      images: [
        'https://cdn.dummyjson.com/product-images/sports-accessories/baseball-ball/thumbnail.webp'
      ],
      thumbnail:
          'https://cdn.dummyjson.com/product-images/sports-accessories/baseball-ball/thumbnail.webp',
    ),
  ];

  Future<List<Product>> getAllProducts() async {
    final baseUrl = host ?? 'https://dummyjson.com';
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/products'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List productsJson = data['products'] ?? [];
        final List<Product> fetchedList =
            productsJson.map((json) => Product.fromJson(json)).toList();

        // Always place the 4 Cart products at the top of Home screen
        final List<Product> result = List.from(_featuredCartProducts);
        for (final p in fetchedList) {
          if (!result.any((item) => item.id == p.id)) {
            result.add(p);
          }
        }
        return result;
      }
    } catch (_) {
      // Fallback: If network fails or web CORS triggers, return featured items
    }

    return _featuredCartProducts;
  }

  Future<Product> getProductById(int id) async {
    final matchingFeatured =
        _featuredCartProducts.where((p) => p.id == id).toList();
    if (matchingFeatured.isNotEmpty) {
      return matchingFeatured.first;
    }

    final baseUrl = host ?? 'https://dummyjson.com';
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromJson(data);
      }
    } catch (_) {
      // Fallback
    }

    return _featuredCartProducts.first;
  }
}
