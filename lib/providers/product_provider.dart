import 'package:flutter/foundation.dart' hide Category;
import '../models/category.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;

  ProductProvider(this._repository);

  // Home
  List<Product> _bestSellers = [];
  List<Product> _newArrivals = [];
  List<Category> _categories = [];
  bool _isHomeLoading = false;

  // Product List
  List<Product> _products = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalProducts = 0;
  bool _isProductListLoading = false;

  // Product Detail
  Product? _selectedProduct;
  bool _isDetailLoading = false;

  String? _error;

  List<Product> get bestSellers => _bestSellers;
  List<Product> get newArrivals => _newArrivals;
  List<Category> get categories => _categories;
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isHomeLoading => _isHomeLoading;
  bool get isProductListLoading => _isProductListLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isLoadingMore => _isProductListLoading && _products.isNotEmpty;
  bool get hasMore => _currentPage < _lastPage;
  int get totalProducts => _totalProducts;
  String? get error => _error;

  Future<void> loadHomeData() async {
    _isHomeLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getHomeData();
      _bestSellers = data['best_sellers'] as List<Product>;
      _newArrivals = data['new_arrivals'] as List<Product>;
      _categories = data['categories'] as List<Category>;
    } catch (e) {
      _error = 'Gagal memuat data';
    } finally {
      _isHomeLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({String? categorySlug, String? search, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
    }

    _isProductListLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getProducts(
        categorySlug: categorySlug,
        search: search,
        page: _currentPage,
      );
      _products.addAll(data['products'] as List<Product>);
      _currentPage = data['current_page'] as int;
      _lastPage = data['last_page'] as int;
      _totalProducts = data['total'] as int;
    } catch (e) {
      _error = 'Gagal memuat produk';
    } finally {
      _isProductListLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts({String? categorySlug, String? search}) async {
    if (_isProductListLoading || !hasMore) return;
    _currentPage++;
    await loadProducts(categorySlug: categorySlug, search: search);
  }

  Future<void> loadProductDetail(int id) async {
    _isDetailLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await _repository.getProductDetail(id);
    } catch (e) {
      _error = 'Gagal memuat detail produk';
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedProduct() {
    _selectedProduct = null;
  }
}
