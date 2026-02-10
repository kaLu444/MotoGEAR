import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  AuthProvider(this._service);

  bool _loading = false;
  String? _error;
  AuthUser? _user;

  bool get loading => _loading;
  String? get error => _error;

  bool get isLoggedIn => _user != null;
  AuthUser? get user => _user;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  bool _looksLikeEmail(String v) {
    final s = v.trim();
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(s);
  }

  Future<void> loadSession() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _service.getCurrentUser();
    } catch (e) {
      _error = AuthService.friendlyError(e);
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final em = email.trim();

    if (em.isEmpty) {
      _loading = false;
      _error = 'Unesi email.';
      notifyListeners();
      return;
    }
    if (!_looksLikeEmail(em)) {
      _loading = false;
      _error = 'Email nije ispravan.';
      notifyListeners();
      return;
    }
    if (password.isEmpty) {
      _loading = false;
      _error = 'Unesi lozinku.';
      notifyListeners();
      return;
    }

    try {
      _user = await _service.login(email: em, password: password);
    } catch (e) {
      _error = AuthService.friendlyError(e);
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final nm = name.trim();
    final em = email.trim();

    if (nm.isEmpty) {
      _loading = false;
      _error = 'Unesi ime i prezime.';
      notifyListeners();
      return;
    }
    if (em.isEmpty) {
      _loading = false;
      _error = 'Unesi email.';
      notifyListeners();
      return;
    }
    if (!_looksLikeEmail(em)) {
      _loading = false;
      _error = 'Email nije ispravan.';
      notifyListeners();
      return;
    }
    if (password.isEmpty) {
      _loading = false;
      _error = 'Unesi lozinku.';
      notifyListeners();
      return;
    }
    if (password.length < 6) {
      _loading = false;
      _error = 'Lozinka mora imati bar 6 karaktera.';
      notifyListeners();
      return;
    }

    try {
      _user = await _service.register(name: nm, email: em, password: password);
    } catch (e) {
      _error = AuthService.friendlyError(e);
      _user = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
  }) async {
    if (_user == null) {
      _error = 'Nisi prijavljen.';
      notifyListeners();
      return;
    }

    final nm = fullName.trim();
    final em = email.trim();

    if (nm.isEmpty) {
      _error = 'Unesi ime i prezime.';
      notifyListeners();
      return;
    }
    if (em.isEmpty) {
      _error = 'Unesi email.';
      notifyListeners();
      return;
    }
    if (!_looksLikeEmail(em)) {
      _error = 'Email nije ispravan.';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateProfile(fullName: nm, email: em);
      _user = _user!.copyWith(name: nm, email: em);
    } catch (e) {
      _error = AuthService.friendlyError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.logout();
      _user = null;
    } catch (e) {
      _error = AuthService.friendlyError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
