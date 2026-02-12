
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cart_item.dart';
import '../models/shipping_address.dart';

class OrdersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ordersCol(String uid) =>
      _db.collection('orders').doc(uid).collection('items');

  Future<void> placeOrder({
    required String uid,
    required List<CartItem> items,
    required double total,
    required ShippingAddress shipping,
  }) async {
    if (uid.isEmpty) throw StateError('NOT_LOGGED_IN');
    if (items.isEmpty) throw StateError('CART_EMPTY');
    if (!shipping.isValid) throw StateError('INVALID_ADDRESS');

    final ref = _ordersCol(uid).doc(); 

    await ref.set({
      'uid': uid, 
      'status': 'placed',
      'total': total,
      'shipping': shipping.toMap(),
      'items': items.map((x) => x.toMap()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelOrder({
    required String uid,
    required String orderId,
  }) async {
    if (uid.isEmpty) throw StateError('NOT_LOGGED_IN');
    if (orderId.isEmpty) throw StateError('INVALID_ORDER_ID');

    final ref = _ordersCol(uid).doc(orderId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw StateError('ORDER_NOT_FOUND');

      final data = snap.data() as Map<String, dynamic>;
      final status = (data['status'] as String?) ?? 'placed';

      const canCancel = {'placed', 'paid'};
      if (!canCancel.contains(status)) {
        throw StateError('CANNOT_CANCEL_STATUS:$status');
      }

      tx.update(ref, {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<List<Map<String, dynamic>>> watchOrdersRaw(String uid) {
    return _ordersCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
