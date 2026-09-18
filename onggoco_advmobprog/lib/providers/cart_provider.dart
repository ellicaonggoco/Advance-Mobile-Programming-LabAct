import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  final UserService _userService = UserService();
  Cart? _cart;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentUserId = 1;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentUserId => _currentUserId;

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
  // ENHANCEMENT 3: Based on the saved user data render the cart by userId
  // --------------------------------------------------------------
  Future<void> loadCart([int? userId]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      int targetUserId = userId ?? _currentUserId;
      if (userId == null) {
        final userData = await _userService.getUserData();
        final savedId = userData['id'] as int? ?? 0;
        if (savedId > 0) {
          targetUserId = savedId;
        }
      }
      _currentUserId = targetUserId;

      _cart = await _cartService.getCartByUserId(_currentUserId).catchError((_) {
        return _cartService.getCartById(_currentUserId);
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
    _cart ??= Cart(
      id: 1,
      products: [],
      total: 0.0,
      discountedTotal: 0.0,
      userId: _currentUserId,
      totalProducts: 0,
      totalQuantity: 0,
    );

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
        userId: _currentUserId,
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
