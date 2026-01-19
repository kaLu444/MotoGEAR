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
