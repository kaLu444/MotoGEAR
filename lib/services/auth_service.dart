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

  AuthUser copyWith({
    String? id,
    String? name,
    String? email,
    bool? isAdmin,
  }) {
    return AuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Future<AuthUser?> getCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _hydrateUser(u);
  }

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;
    return _hydrateUser(user);
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

    final uid = cred.user!.uid;

    await _userDoc(uid).set({
      'fullName': name,
      'email': email,
      'isAdmin': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    
    await cred.user!.updateDisplayName(name);

    return AuthUser(id: uid, name: name, email: email, isAdmin: false);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
  }) async {
    final u = _auth.currentUser;
    if (u == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }

    final uid = u.uid;
    final nm = fullName.trim();
    final em = email.trim();

    await _userDoc(uid).set({
      'fullName': nm,
      'email': em,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (nm.isNotEmpty && (u.displayName ?? '') != nm) {
      await u.updateDisplayName(nm);
    }

    if (em.isNotEmpty && (u.email ?? '') != em) {
      
      await u.verifyBeforeUpdateEmail(em);
    }
  }

  Future<AuthUser> _hydrateUser(User u) async {
    final ref = _userDoc(u.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'fullName': u.displayName ?? '',
        'email': u.email ?? '',
        'isAdmin': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final data = (await ref.get()).data() ?? {};

    final name = (data['fullName'] as String?)?.trim().isNotEmpty == true
        ? (data['fullName'] as String).trim()
        : ((u.displayName ?? '').trim().isNotEmpty
            ? u.displayName!.trim()
            : 'User');

    final email = (data['email'] as String?)?.trim().isNotEmpty == true
        ? (data['email'] as String).trim()
        : (u.email ?? '');

    final isAdmin = (data['isAdmin'] as bool?) ?? false;

    return AuthUser(
      id: u.uid,
      name: name,
      email: email,
      isAdmin: isAdmin,
    );
  }

  static String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
        case 'invalid-new-email':
          return 'Email nije ispravan.';
        case 'missing-email':
          return 'Unesi email.';
        case 'missing-password':
          return 'Unesi lozinku.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email ili lozinka nisu ispravni.';
        case 'email-already-in-use':
          return 'Ovaj email je već registrovan.';
        case 'weak-password':
          return 'Lozinka mora imati bar 6 karaktera.';
        case 'network-request-failed':
          return 'Nema internet konekcije.';
        case 'too-many-requests':
          return 'Previše pokušaja. Pokušaj kasnije.';
        case 'operation-not-allowed':
          return 'Email/Password prijava nije uključena u Firebase Console.';
        case 'requires-recent-login':
          return 'Prijavi se ponovo da bi promenio email.';
        case 'no-current-user':
          return 'Nisi prijavljen.';
        default:
          return 'Greška pri autentifikaciji. Pokušaj ponovo.';
      }
    }

    return 'Došlo je do greške. Pokušaj ponovo.';
  }
}
