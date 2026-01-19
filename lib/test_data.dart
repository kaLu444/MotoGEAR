import '../models/product.dart';
import '../services/assets_manager.dart';

class TestData {
  static const List<Product> products = [
    Product(
      id: 'gpforce',
      category: 'Jackets',
      title: 'GP Force V2 Air Leather Jacket',
      subtitle: 'Tech-Air® Ready',
      priceLabel: '€409,95',
      priceValue: 409.95,
      images: [AssetsManager.gpforceFront, AssetsManager.gpforceBack],
      coverImage: AssetsManager.gpforceFront,
      techAirReady: true,
      waterproof: false,
    ),
    Product(
      id: 'wt8',
      category: 'Gloves',
      title: 'WT-8 Gore-Tex Insulated Gloves',
      subtitle: 'CE Certified',
      priceLabel: '€79,95',
      priceValue: 79.95,
      images: [AssetsManager.glovesFront, AssetsManager.glovesBack],
      coverImage: AssetsManager.glovesFront,
      techAirReady: false,
      waterproof: true,
    ),
    Product(
      id: 'drystar',
      category: 'Boots',
      title: 'Drystar Shoes',
      subtitle: 'Waterproof',
      priceLabel: '€139,95',
      priceValue: 139.95,
      images: [AssetsManager.drystarShoes, AssetsManager.drystarShoesPair],
      coverImage: AssetsManager.drystarShoes,
      techAirReady: false,
      waterproof: true,
    ),
    Product(
      id: 'helmet',
      category: 'Helmets',
      title: 'Supertech R10 Solid Helmet',
      subtitle: 'Safety & Performance',
      priceLabel: '€159,95',
      priceValue: 159.95,
      images: [AssetsManager.helmet, AssetsManager.helmetFront],
      coverImage: AssetsManager.helmet,
      techAirReady: false,
      waterproof: false,
    ),
  ];
}
