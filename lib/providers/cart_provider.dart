import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import 'auth_provider.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service;
  CartProvider(this._service);

  String? _uid;
  StreamSubscription<List<CartItem>>? _sub;

  bool _loading = false;
  String? _error;
  List<CartItem> _items = [];

  bool get loading => _loading;
  String? get error => _error;
  List<CartItem> get items => List.unmodifiable(_items);

  int get cartCount => _items.fold<int>(0, (sum, x) => sum + x.quantity);
  double get total => _items.fold<double>(0, (sum, x) => sum + x.lineTotal);

  void updateAuth(AuthProvider auth) {
    final newUid = auth.user?.id;
    if (newUid == _uid) return;
    _uid = newUid;
    _bind();
  }

  void _bind() {
    _sub?.cancel();
    _sub = null;

    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _items = [];
      _loading = false;
      _error = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    _sub = _service.watchCart(uid: uid).listen(
      (data) {
        _items = data;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        _items = [];
        notifyListeners();
      },
    );
  }

  Future<void> addToCart({required Product product, required String size}) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _error = 'NOT_LOGGED_IN';
      notifyListeners();
      return;
    }
    await _service.addToCart(uid: uid, product: product, size: size);
  }

  Future<void> increment(String cartItemId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    await _service.increment(uid: uid, cartItemId: cartItemId);
  }

  Future<void> decrement(String cartItemId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    await _service.decrement(uid: uid, cartItemId: cartItemId);
  }

  Future<void> remove(String cartItemId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    await _service.remove(uid: uid, cartItemId: cartItemId);
  }

  Future<void> updateItemSize({
    required String cartItemId,
    required Product product,
    required String oldSize,
    required String newSize,
  }) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    await _service.changeSize(uid: uid, product: product, oldSize: oldSize, newSize: newSize);
  }

  Future<void> clear() async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) return;
    await _service.clear(uid: uid);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
