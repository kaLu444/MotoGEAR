import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service;
  CartProvider(this._service);

  bool _loading = false;
  String? _error;

  final List<CartItem> _items = [];

  bool get loading => _loading;
  String? get error => _error;

  List<CartItem> get items => List.unmodifiable(_items);

  int get cartCount => _items.fold<int>(0, (sum, x) => sum + x.quantity);

  double get total => _items.fold<double>(0, (sum, x) => sum + x.lineTotal);

  Future<void> loadCart() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.fetchCart();
      _items
        ..clear()
        ..addAll(data);
    } catch (e) {
      _error = e.toString();
      _items.clear();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void addToCart({required Product product, required String size}) {
    final idx = _items.indexWhere(
      (x) => x.product.id == product.id && x.size == size,
    );

    if (idx != -1) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    } else {
      _items.add(
        CartItem(
          id: 'cart_${DateTime.now().microsecondsSinceEpoch}',
          product: product,
          size: size,
          quantity: 1,
          inStock: true,
        ),
      );
    }

    notifyListeners();
  }

  void updateItemSize({required String cartItemId, required String newSize}) {
    final idx = _items.indexWhere((x) => x.id == cartItemId);
    if (idx == -1) return;

    final current = _items[idx];

    if (current.size == newSize) return;

    final mergeIdx = _items.indexWhere(
      (x) =>
          x.id != cartItemId &&
          x.product.id == current.product.id &&
          x.size == newSize,
    );

    if (mergeIdx != -1) {
      final mergedQty = _items[mergeIdx].quantity + current.quantity;
      _items[mergeIdx] = _items[mergeIdx].copyWith(quantity: mergedQty);
      _items.removeAt(idx);
    } else {
      _items[idx] = current.copyWith(size: newSize);
    }

    notifyListeners();
  }

  void increment(String cartItemId) {
    final idx = _items.indexWhere((x) => x.id == cartItemId);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
    notifyListeners();
  }

  void decrement(String cartItemId) {
    final idx = _items.indexWhere((x) => x.id == cartItemId);
    if (idx == -1) return;

    final q = _items[idx].quantity;
    if (q <= 1) {
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(quantity: q - 1);
    }
    notifyListeners();
  }

  void remove(String cartItemId) {
    _items.removeWhere((x) => x.id == cartItemId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
