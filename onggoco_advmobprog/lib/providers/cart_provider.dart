import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  Cart? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get subtotal {
    if (_cart == null) return 0.0;
    return _cart!.products.fold(0.0, (sum, item) => sum + item.total);
  }

  double get discountedTotal {
    if (_cart == null) return 0.0;
    return _cart!.products.fold(0.0, (sum, item) => sum + item.discountedTotal);
  }

  int get itemCount {
    if (_cart == null) return 0;
    return _cart!.products.fold(0, (sum, item) => sum + item.quantity);
  }

  // --------------------------------------------------------------
  // Load initial cart data (User ID: 1 as required by assignment)
  // --------------------------------------------------------------
  Future<void> loadCart() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.getCartByUserId(1).catchError((_) {
        return _cartService.getCartById(1);
      });
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --------------------------------------------------------------
  // ENHANCEMENT 3: Add product to cart & dynamically update state
  // --------------------------------------------------------------
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_cart == null) {
      _cart = Cart(
        id: 1,
        products: [],
        total: 0.0,
        discountedTotal: 0.0,
        userId: 1,
        totalProducts: 0,
        totalQuantity: 0,
      );
    }

    final existingIndex = _cart!.products.indexWhere((p) => p.id == product.id);

    if (existingIndex != -1) {
      final existing = _cart!.products[existingIndex];
      final newQty = existing.quantity + quantity;
      final newTotal = product.price * newQty;
      final newDiscountedTotal =
          (product.price * (1 - product.discountPercentage / 100)) * newQty;

      _cart!.products[existingIndex] = CartProduct(
        id: product.id,
        title: product.title,
        price: product.price,
        quantity: newQty,
        total: newTotal,
        discountPercentage: product.discountPercentage,
        discountedTotal: newDiscountedTotal,
        thumbnail: product.thumbnail,
      );
    } else {
      final total = product.price * quantity;
      final discountedTotal =
          (product.price * (1 - product.discountPercentage / 100)) * quantity;

      _cart!.products.add(
        CartProduct(
          id: product.id,
          title: product.title,
          price: product.price,
          quantity: quantity,
          total: total,
          discountPercentage: product.discountPercentage,
          discountedTotal: discountedTotal,
          thumbnail: product.thumbnail,
        ),
      );
    }

    notifyListeners();

    // Asynchronously send to DummyJSON backend
    try {
      await _cartService.addToCart(
        userId: 1,
        products: [
          {
            'id': product.id,
            'quantity': quantity,
          }
        ],
      );
    } catch (_) {
      // Keep local state intact even if mock backend is offline
    }
  }

  // --------------------------------------------------------------
  // Quantity update from cart stepper (+ / -)
  // --------------------------------------------------------------
  void updateQuantity(CartProduct item, int delta) {
    if (_cart == null) return;

    final index = _cart!.products.indexWhere((p) => p.id == item.id);
    if (index != -1) {
      final newQty = _cart!.products[index].quantity + delta;

      if (newQty > 0) {
        final newTotal = item.price * newQty;
        final newDiscountedTotal =
            (item.price * (1 - item.discountPercentage / 100)) * newQty;

        _cart!.products[index] = CartProduct(
          id: item.id,
          title: item.title,
          price: item.price,
          quantity: newQty,
          total: newTotal,
          discountPercentage: item.discountPercentage,
          discountedTotal: newDiscountedTotal,
          thumbnail: item.thumbnail,
        );
      } else {
        _cart!.products.removeAt(index);
      }
      notifyListeners();
    }
  }
}
