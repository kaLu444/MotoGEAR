import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item.dart';
import 'shipping_address.dart';

class Order {
  final String id;
  final String uid;
  final List<CartItem> items;
  final double total;
  final ShippingAddress shipping;
  final String status; 
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.uid,
    required this.items,
    required this.total,
    required this.shipping,
    required this.status,
    required this.createdAt,
  });

  static DateTime _parseCreatedAt(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  factory Order.fromMap({
    required String id,
    required String uid,
    required Map<String, dynamic> data,
  }) {
    final itemsRaw = (data['items'] as List?) ?? const [];
    final items = itemsRaw
        .whereType<Map>()
        .map((m) => CartItem.fromMap(
              
              '${id}_${(m['productId'] ?? m['product']?['id'] ?? '')}_${(m['size'] ?? '')}',
              Map<String, dynamic>.from(m),
            ))
        .toList();

    final shippingRaw = data['shipping'];
    final shipping = (shippingRaw is Map<String, dynamic>)
        ? ShippingAddress.fromMap(shippingRaw)
        : ShippingAddress.empty();

    return Order(
      id: id,
      uid: uid,
      items: items,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      shipping: shipping,
      status: (data['status'] as String?) ?? 'placed',
      createdAt: _parseCreatedAt(data['createdAt']),
    );
  }
}
