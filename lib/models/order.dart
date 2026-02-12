import 'cart_item.dart';
import 'shipping_address.dart';

class Order {
  final String id;
  final String uid;
  final List<CartItem> items;
  final double total;
  final ShippingAddress shipping;
  final String status; // "placed"
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
}
