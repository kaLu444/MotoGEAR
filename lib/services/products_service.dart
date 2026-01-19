import '../models/product.dart';
import '../test_data.dart';

class ProductsService {
  Future<List<Product>> fetchProducts() async {
    return TestData.products;
  }
}
