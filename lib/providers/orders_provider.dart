
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../services/orders_service.dart';
import 'auth_provider.dart';

class OrdersProvider extends ChangeNotifier {
  final OrdersService _service;
  OrdersProvider(this._service);

  String? _uid;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  bool _loading = false;
  String? _error;
  List<Order> _orders = [];

  final Set<String> _cancelling = {};
  bool isCancelling(String orderId) => _cancelling.contains(orderId);

  bool get loading => _loading;
  String? get error => _error;
  List<Order> get orders => List.unmodifiable(_orders);

  void updateAuth(AuthProvider auth) {
    final newUid = auth.user?.id;
    if (newUid == _uid) return;
    _uid = newUid;
    _bind();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _error = 'NOT_LOGGED_IN';
      notifyListeners();
      return;
    }

    if (orderId.isEmpty) return;
    if (_cancelling.contains(orderId)) return;

    _cancelling.add(orderId);
    _error = null;
    notifyListeners();

    try {
      await _service.cancelOrder(uid: uid, orderId: orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _cancelling.remove(orderId);
      notifyListeners();
    }
  }

  void _bind() {
    _sub?.cancel();
    _sub = null;

    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _loading = false;
      _error = null;
      _orders = [];
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    _orders = [];
    notifyListeners();

    _sub = _service.watchOrdersRaw(uid).listen(
      (raw) {
        _orders = raw.map((m) {
          final id = (m['id'] as String?) ?? '';
          return Order.fromMap(
            id: id,
            uid: uid,
            data: Map<String, dynamic>.from(m),
          );
        }).toList();

        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        _orders = [];
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
