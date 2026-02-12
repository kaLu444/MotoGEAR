
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> watchAllOrdersRaw() {
    return _db
        .collectionGroup('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
