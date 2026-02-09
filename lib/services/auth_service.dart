import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.isAdmin,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AuthUser?> getCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _loadUser(u);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _loadUser(cred.user!);
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final u = cred.user!;
    await u.updateDisplayName(name);
    await u.reload();

    // napravi user doc (isAdmin mora biti false)
    await _db.collection('users').doc(u.uid).set({
      'fullName': name,
      'email': email,
      'isAdmin': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return _loadUser(_auth.currentUser!);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AuthUser> _loadUser(User u) async {
    final doc = await _db.collection('users').doc(u.uid).get();

    // ako doc ne postoji (npr. stari user), kreiraj default
    if (!doc.exists) {
      await _db.collection('users').doc(u.uid).set({
        'fullName': u.displayName ?? '',
        'email': u.email ?? '',
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final data = (await _db.collection('users').doc(u.uid).get()).data() ?? {};
    final isAdmin = (data['isAdmin'] == true);

    return AuthUser(
      id: u.uid,
      name: (data['fullName'] as String?) ?? (u.displayName ?? ''),
      email: (data['email'] as String?) ?? (u.email ?? ''),
      isAdmin: isAdmin,
    );
  }
}
