import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _itemsCol(String uid) =>
      _db.collection('carts').doc(uid).collection('items');

  
  
  Future<List<CartItem>> fetchCart({String? uid}) async {
    if (uid == null || uid.isEmpty) return [];

    final snap = await _itemsCol(uid).get();
    return snap.docs.map((d) => CartItem.fromMap(d.id, d.data())).toList();
  }

  
  Stream<List<CartItem>> watchCart({String? uid}) {
    if (uid == null || uid.isEmpty) {
      return Stream.value(<CartItem>[]);
    }

    
    return _itemsCol(uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => CartItem.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> addToCart({
    required String uid,
    required Product product,
    required String size,
  }) async {
    final docId = '${product.id}_$size';
    final ref = _itemsCol(uid).doc(docId);

    await _db.runTransaction((tx) async {
      final doc = await tx.get(ref);

      if (!doc.exists) {
        tx.set(ref, {
          'product': product.toMap(),
          'productId': product.id,
          'size': size,
          'quantity': 1,
          'inStock': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(ref, {
          'quantity': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> increment({
    required String uid,
    required String cartItemId,
  }) async {
    final ref = _itemsCol(uid).doc(cartItemId);
    await ref.update({
      'quantity': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> decrement({
    required String uid,
    required String cartItemId,
  }) async {
    final ref = _itemsCol(uid).doc(cartItemId);

    await _db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (!doc.exists) return;

      final q = (doc.data()?['quantity'] as int?) ?? 1;

      if (q <= 1) {
        tx.delete(ref);
      } else {
        tx.update(ref, {
          'quantity': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> remove({
    required String uid,
    required String cartItemId,
  }) async {
    await _itemsCol(uid).doc(cartItemId).delete();
  }

  
  Future<void> changeSize({
    required String uid,
    required Product product,
    required String oldSize,
    required String newSize,
  }) async {
    if (oldSize == newSize) return;

    final oldId = '${product.id}_$oldSize';
    final newId = '${product.id}_$newSize';

    final oldRef = _itemsCol(uid).doc(oldId);
    final newRef = _itemsCol(uid).doc(newId);

    await _db.runTransaction((tx) async {
      final oldDoc = await tx.get(oldRef);
      if (!oldDoc.exists) return;

      final oldData = Map<String, dynamic>.from(oldDoc.data()!);
      final oldQty = (oldData['quantity'] as int?) ?? 1;

      final newDoc = await tx.get(newRef);

      if (newDoc.exists) {
        tx.update(newRef, {
          'quantity': FieldValue.increment(oldQty),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        tx.delete(oldRef);
      } else {
        oldData['size'] = newSize;
        oldData['updatedAt'] = FieldValue.serverTimestamp();
        tx.set(newRef, oldData);
        tx.delete(oldRef);
      }
    });
  }

  
  Future<void> updateItemSize({
    required String uid,
    required Product product,
    required String oldSize,
    required String newSize,
  }) =>
      changeSize(uid: uid, product: product, oldSize: oldSize, newSize: newSize);

  Future<void> clear({required String uid}) async {
    final snap = await _itemsCol(uid).get();
    final batch = _db.batch();

    for (final d in snap.docs) {
      batch.delete(d.reference);
    }

    await batch.commit();
  }
}
