class Product {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String priceLabel;
  final double priceValue;
  final List<String> images;
  final String coverImage;

  final bool techAirReady;
  final bool waterproof;

  // da izbaciš hardkod u details
  final List<String> bullets;
  final List<String> sizes;

  const Product({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.priceValue,
    required this.images,
    required this.coverImage,
    required this.techAirReady,
    required this.waterproof,
    required this.bullets,
    required this.sizes,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      category: (data['category'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      subtitle: (data['subtitle'] as String?) ?? '',
      priceLabel: (data['priceLabel'] as String?) ?? '',
      priceValue: (data['priceValue'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from((data['images'] as List?) ?? const []),
      coverImage: (data['coverImage'] as String?) ?? '',
      techAirReady: (data['techAirReady'] as bool?) ?? false,
      waterproof: (data['waterproof'] as bool?) ?? false,
      bullets: List<String>.from((data['bullets'] as List?) ?? const []),
      sizes: List<String>.from((data['sizes'] as List?) ?? const ['S', 'M', 'L', 'XL', 'XXL']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'subtitle': subtitle,
      'priceLabel': priceLabel,
      'priceValue': priceValue,
      'images': images,
      'coverImage': coverImage,
      'techAirReady': techAirReady,
      'waterproof': waterproof,
      'bullets': bullets,
      'sizes': sizes,
    };
  }
}
