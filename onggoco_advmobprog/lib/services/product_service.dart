import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> getAllProducts() async {
    final baseUrl = host ?? 'https://dummyjson.com';
    final response = await http.get(Uri.parse('$baseUrl/products?limit=0'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List productsJson = data['products'] ?? [];
      final List<Product> list =
          productsJson.map((json) => Product.fromJson(json)).toList();

      // Ensure the exact cart items appear at the very top of Home Screen
      const cartProductIds = [162, 113, 122, 138];
      list.sort((a, b) {
        final aIndex = cartProductIds.indexOf(a.id);
        final bIndex = cartProductIds.indexOf(b.id);
        if (aIndex != -1 && bIndex != -1) return aIndex.compareTo(bIndex);
        if (aIndex != -1) return -1;
        if (bIndex != -1) return 1;
        return 0;
      });

      return list;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> getProductById(int id) async {
    final baseUrl = host ?? 'https://dummyjson.com';
    final response = await http.get(Uri.parse('$baseUrl/products/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to load product with id: $id');
    }
  }
}
