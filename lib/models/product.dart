class Product {
  final String id;
  final String category; // Jackets, Gloves, Boots, Helmets
  final String title;
  final String subtitle;
  final String priceLabel; // "€409,95"
  final double priceValue; // 409.95 (kasnije za sort/filter)
  final List<String> images; // 2 slike
  final String coverImage; // za karticu u gridu

  final bool techAirReady;
  final bool waterproof;

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
  });
}
