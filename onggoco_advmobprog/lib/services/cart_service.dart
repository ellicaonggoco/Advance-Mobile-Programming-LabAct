import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/cart.dart';

class CartService {
  Future<List<Cart>> getAllCarts() async {
    final baseUrl = host ?? 'https://dummyjson.com';
    final response = await http.get(Uri.parse('$baseUrl/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      return cartsJson.map((json) => Cart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load carts');
    }
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 3: Read Cart documentation https://dummyjson.com/docs/carts
  // Integrate cart by user ID (https://dummyjson.com/carts/user/{userId})
  // --------------------------------------------------------------
  Future<Cart> getCartByUserId(int userId) async {
    final baseUrl = host ?? 'https://dummyjson.com';
    final response = await http.get(Uri.parse('$baseUrl/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      if (cartsJson.isNotEmpty) {
        return Cart.fromJson(cartsJson.first);
      }
      throw Exception('No cart found for user ID: $userId');
    } else {
      throw Exception('Failed to load cart for user ID: $userId');
    }
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 3: Get Cart by cart ID (https://dummyjson.com/carts/{id})
  // --------------------------------------------------------------
  Future<Cart> getCartById(int cartId) async {
    final baseUrl = host ?? 'https://dummyjson.com';
    final response = await http.get(Uri.parse('$baseUrl/carts/$cartId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to load cart with id: $cartId');
    }
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 3: Add to cart by passing product values (POST https://dummyjson.com/carts/add)
  // --------------------------------------------------------------
  Future<Map<String, dynamic>> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    final baseUrl = host ?? 'https://dummyjson.com';
    final response = await http.post(
      Uri.parse('$baseUrl/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': products,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add product to cart');
    }
  }
}