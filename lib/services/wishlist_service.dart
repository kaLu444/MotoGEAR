import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('wishlists').doc(uid).collection('items');

  Stream<Set<String>> watchWishlistIds({required String uid}) {
    return _col(uid).snapshots().map((snap) {
      return snap.docs.map((d) => d.id).toSet();
    });
  }

  Future<void> add({required String uid, required String productId}) async {
    await _col(uid).doc(productId).set({
      'productId': productId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> remove({required String uid, required String productId}) async {
    await _col(uid).doc(productId).delete();
  }
}
