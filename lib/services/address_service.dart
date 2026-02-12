import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shipping_address.dart';

class AddressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  Future<ShippingAddress?> fetchAddress(String uid) async {
    final snap = await _userDoc(uid).get();
    final data = snap.data() ?? {};
    final addr = data['shippingAddress'];
    if (addr is Map<String, dynamic>) {
      return ShippingAddress.fromMap(addr);
    }
    return null;
  }

  Stream<ShippingAddress?> watchAddress(String uid) {
    return _userDoc(uid).snapshots().map((snap) {
      final data = snap.data() ?? {};
      final addr = data['shippingAddress'];
      if (addr is Map<String, dynamic>) return ShippingAddress.fromMap(addr);
      return null;
    });
  }

  Future<void> saveAddress(String uid, ShippingAddress address) async {
    await _userDoc(uid).set({
      'shippingAddress': address.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearAddress(String uid) async {
    await _userDoc(uid).set({
      'shippingAddress': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
