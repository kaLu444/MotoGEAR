import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/products_service.dart';

enum SortOption { featured, priceLowHigh, priceHighLow, nameAZ, nameZA }

class ProductsProvider extends ChangeNotifier {
  final ProductsService _service;

  ProductsProvider(this._service);

  bool _loading = false;
  String? _error;

  List<Product> _all = [];

  SortOption _sort = SortOption.featured;

  double _minPrice = 0;
  double _maxPrice = 800;
  bool _techAirReady = false;
  bool _waterproof = false;

  bool get loading => _loading;
  String? get error => _error;

  SortOption get sort => _sort;
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get techAirReady => _techAirReady;
  bool get waterproof => _waterproof;

  List<String> get tabs {
    final set = <String>{};
    for (final p in _all) {
      set.add(p.category);
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> loadProducts() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _all = await _service.fetchProducts();
    } catch (e) {
      _error = e.toString();
      _all = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void toggleCategory(String category) {
    _selectedCategory = (_selectedCategory == category) ? null : category;
    notifyListeners();
  }

  void setSort(SortOption value) {
    _sort = value;
    notifyListeners();
  }

  void setFilters({
    required double minPrice,
    required double maxPrice,
    required bool techAirReady,
    required bool waterproof,
  }) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _techAirReady = techAirReady;
    _waterproof = waterproof;
    notifyListeners();
  }

  int get activeFilterCount {
    int count = 0;
    if (!(_minPrice == 0 && _maxPrice == 800)) count++;
    if (_techAirReady) count++;
    if (_waterproof) count++;
    return count;
  }

  List<Product> get products {
    var list = List<Product>.from(_all);

    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }

    list = list.where((p) {
      if (p.priceValue < _minPrice || p.priceValue > _maxPrice) return false;
      if (_techAirReady && !p.techAirReady) return false;
      if (_waterproof && !p.waterproof) return false;
      return true;
    }).toList();

    switch (_sort) {
      case SortOption.featured:
        break;

      case SortOption.priceLowHigh:
        list.sort((a, b) => a.priceValue.compareTo(b.priceValue));
        break;

      case SortOption.priceHighLow:
        list.sort((a, b) => b.priceValue.compareTo(a.priceValue));
        break;

      case SortOption.nameAZ:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;

      case SortOption.nameZA:
        list.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
    }

    return list;
  }
}
