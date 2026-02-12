// lib/seeder.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'seed.dart';

class DevSeeder {
  static final _db = FirebaseFirestore.instance;

  static Future<void> seedProductsOnce() async {
    final col = _db.collection('products');

    // "samo jednom": proveri da li već postoje svi doc-ovi
    final ids = seedProducts.map((p) => p["id"] as String).toList();
    final snaps = await Future.wait(ids.map((id) => col.doc(id).get()));

    final alreadyAll = snaps.every((d) => d.exists);
    if (alreadyAll) return;

    final batch = _db.batch();
    final now = FieldValue.serverTimestamp();

    for (final p in seedProducts) {
      final id = p["id"] as String;
      batch.set(
        col.doc(id),
        {
          ...p,
          "createdAt": now,
          "updatedAt": now,
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}
