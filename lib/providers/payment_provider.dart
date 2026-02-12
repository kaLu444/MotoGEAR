import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/payment_card.dart';
import '../services/payment_service.dart';
import 'auth_provider.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _service;
  PaymentProvider(this._service);

  String? _uid;
  StreamSubscription<PaymentCard?>? _sub;

  bool _loading = false;
  String? _error;
  PaymentCard? _card;

  bool get loading => _loading;
  String? get error => _error;
  PaymentCard? get card => _card;

  void updateAuth(AuthProvider auth) {
    final newUid = auth.user?.id;
    if (newUid == _uid) return;
    _uid = newUid;
    _bind();
  }

  Future<void> save(PaymentCard c) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _error = 'NOT_LOGGED_IN';
      notifyListeners();
      return;
    }
    if (!c.isValid) {
      _error = 'INVALID_CARD';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.saveCard(uid, c);
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> delete() async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      _error = 'NOT_LOGGED_IN';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.clearCard(uid);
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
      _card = null;
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    _card = null;
    notifyListeners();

    _sub = _service.watchCard(uid).listen(
      (c) {
        _card = c;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        _card = null;
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
