class AuthUser {
  final String id;
  final String name;
  final String email;

  const AuthUser({required this.id, required this.name, required this.email});
}

class AuthService {
  AuthUser? _current;

  Future<AuthUser?> getCurrentUser() async {
    return _current;
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    _current = AuthUser(id: 'u_1', name: 'Marko Nikolic', email: email);
    return _current!;
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _current = AuthUser(id: 'u_1', name: name, email: email);
    return _current!;
  }

  Future<void> logout() async {
    _current = null;
  }
}
