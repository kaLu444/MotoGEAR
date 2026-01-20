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

  Future<void> loadSession() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _service.getCurrentUser();
    } catch (e) {
      _error = e.toString();
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

    try {
      _user = await _service.login(email: email, password: password);
    } catch (e) {
      _error = e.toString();
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

    try {
      _user = await _service.register(name: name, email: email, password: password);
    } catch (e) {
      _error = e.toString();
      _user = null;
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
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
