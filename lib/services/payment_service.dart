import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_card.dart';

class PaymentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Stream<PaymentCard?> watchCard(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data() ?? {};
      final c = data['paymentCard'];
      if (c is Map<String, dynamic>) return PaymentCard.fromMap(c);
      return null;
    });
  }

  Future<void> saveCard(String uid, PaymentCard card) async {
    await _userDoc(uid).set({
      'paymentCard': card.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearCard(String uid) async {
    await _userDoc(uid).set({
      'paymentCard': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
