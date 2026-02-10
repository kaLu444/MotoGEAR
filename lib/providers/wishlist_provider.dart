import 'dart:async';
import 'package:flutter/foundation.dart';

import '../providers/auth_provider.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistService _service;
  WishlistProvider(this._service);

  String? _uid;
  StreamSubscription<Set<String>>? _sub;

  bool _loading = false;
  String? _error;
  Set<String> _ids = {};

  bool get loading => _loading;
  String? get error => _error;
  Set<String> get ids => Set.unmodifiable(_ids);

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

  bool isWishlisted(String productId) => _ids.contains(productId);

  Future<void> toggle(String productId) async {
    final uid = _uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('NOT_LOGGED_IN');
    }

    _error = null;

    final was = _ids.contains(productId);

    // optimistic update
    final next = {..._ids};
    if (was) {
      next.remove(productId);
    } else {
      next.add(productId);
    }
    _ids = next;
    notifyListeners();

    try {
      if (was) {
        await _service.remove(uid: uid, productId: productId);
      } else {
        await _service.add(uid: uid, productId: productId);
      }
    } catch (e) {
      // rollback
      final rollback = {..._ids};
      if (was) {
        rollback.add(productId);
      } else {
        rollback.remove(productId);
      }
      _ids = rollback;
      _error = e.toString();
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
      _ids = {};
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    _ids = {};
    notifyListeners();

    _sub = _service.watchWishlistIds(uid: uid).listen(
      (ids) {
        _ids = ids;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        _ids = {};
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
