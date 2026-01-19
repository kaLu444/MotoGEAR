import 'product.dart';

class CartItem {
  final String id;
  final Product product;

  final String size; 
  final int quantity;
  final bool inStock;

  const CartItem({
    required this.id,
    required this.product,
    required this.size,
    required this.quantity,
    required this.inStock,
  });

  double get lineTotal => product.priceValue * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    String? size,
    int? quantity,
    bool? inStock,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
      inStock: inStock ?? this.inStock,
    );
  }
}
