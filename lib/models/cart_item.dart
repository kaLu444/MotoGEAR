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

  factory CartItem.fromMap(String id, Map<String, dynamic> data) {
    final productMap =
        Map<String, dynamic>.from((data['product'] as Map?) ?? {});
    final productId =
        (data['productId'] as String?) ?? (productMap['id'] as String?) ?? '';

    final product = Product.fromMap(productId, productMap);

    return CartItem(
      id: id,
      product: product,
      size: (data['size'] as String?) ?? 'M',
      quantity: (data['quantity'] as int?) ?? 1,
      inStock: (data['inStock'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'product': product.toMap(), 
      'size': size,
      'quantity': quantity,
      'inStock': inStock,
    };
  }
}
