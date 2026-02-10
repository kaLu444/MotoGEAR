import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Product>> fetchProducts() async {
    final snap = await _db.collection('products').get();
    return snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList();
  }

  Stream<List<Product>> watchProducts() {
    return _db.collection('products').snapshots().map(
          (snap) => snap.docs.map((d) => Product.fromMap(d.id, d.data())).toList(),
        );
  }
}
