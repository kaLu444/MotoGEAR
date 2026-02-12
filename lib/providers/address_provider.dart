import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/shipping_address.dart';
import '../services/address_service.dart';
import 'auth_provider.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _service;
  AddressProvider(this._service);

  String? _uid;
  StreamSubscription<ShippingAddress?>? _sub;

  bool _loading = false;
  String? _error;
  ShippingAddress? _address;

  bool get loading => _loading;
  String? get error => _error;
  ShippingAddress? get address => _address;

  void updateAuth(AuthProvider auth) {
    final newUid = auth.user?.id;
    if (newUid == _uid) return;
    _uid = newUid;
    _bind();
  }

  Future<void> save(ShippingAddress a) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _error = 'NOT_LOGGED_IN';
      notifyListeners();
      return;
    }
    if (!a.isValid) {
      _error = 'INVALID_ADDRESS';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.saveAddress(uid, a);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  void _bind() {
    _sub?.cancel();
    _sub = null;

    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _loading = false;
      _error = null;
      _address = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    _address = null;
    notifyListeners();

    _sub = _service.watchAddress(uid).listen(
      (a) {
        _address = a;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        _address = null;
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
