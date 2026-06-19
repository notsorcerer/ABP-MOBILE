import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../models/category.dart';
import '../models/dashboard_stats.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository;

  AdminProvider(this._repository);

  DashboardStats? _dashboardStats;
  bool _isDashboardLoading = false;

  List<Product> _products = [];
  int _currentProductPage = 1;
  int _lastProductPage = 1;
  bool _isProductsLoading = false;

  List<Category> _categories = [];
  bool _isCategoriesLoading = false;

  List<Order> _orders = [];
  int _currentOrderPage = 1;
  int _lastOrderPage = 1;
  bool _isOrdersLoading = false;

  Order? _selectedOrder;
  bool _isOrderDetailLoading = false;

  String? _error;
  bool _isMutationLoading = false;

  DashboardStats? get dashboardStats => _dashboardStats;
  bool get isDashboardLoading => _isDashboardLoading;
  List<Product> get products => _products;
  bool get isProductsLoading => _isProductsLoading;
  bool get hasMoreProducts => _currentProductPage < _lastProductPage;
  List<Category> get categories => _categories;
  bool get isCategoriesLoading => _isCategoriesLoading;
  List<Order> get orders => _orders;
  bool get isOrdersLoading => _isOrdersLoading;
  bool get hasMoreOrders => _currentOrderPage < _lastOrderPage;
  Order? get selectedOrder => _selectedOrder;
  bool get isOrderDetailLoading => _isOrderDetailLoading;
  String? get error => _error;
  bool get isMutationLoading => _isMutationLoading;

  String _extractMessage(dynamic e) {
    if (e is DioException) {
      final msg = e.response?.data?['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return 'Terjadi kesalahan';
  }

  Future<void> loadDashboard() async {
    _isDashboardLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardStats = await _repository.getDashboard();
    } catch (e) {
      _error = _extractMessage(e);
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts({bool refresh = false, String? search, int? categoryId}) async {
    if (refresh) {
      _currentProductPage = 1;
      _products = [];
    }

    _isProductsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getProducts(
        page: _currentProductPage,
        search: search,
        categoryId: categoryId,
      );
      _products.addAll(data['products'] as List<Product>);
      _currentProductPage = data['current_page'] as int;
      _lastProductPage = data['last_page'] as int;
    } catch (e) {
      _error = 'Gagal memuat produk';
    } finally {
      _isProductsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreProducts() async {
    if (_isProductsLoading || !hasMoreProducts) return;
    _currentProductPage++;
    await loadProducts();
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imagePath,
    bool isBestSeller = false,
    bool isNewArrival = false,
  }) async {
    _isMutationLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createProduct(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imagePath: imagePath,
        isBestSeller: isBestSeller,
        isNewArrival: isNewArrival,
      );
      _isMutationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _isMutationLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(int id, {
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imagePath,
    bool isBestSeller = false,
    bool isNewArrival = false,
  }) async {
    _isMutationLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProduct(id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imagePath: imagePath,
        isBestSeller: isBestSeller,
        isNewArrival: isNewArrival,
      );
      _isMutationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _isMutationLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isMutationLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteProduct(id);
      _isMutationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _isMutationLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadCategories() async {
    _isCategoriesLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _repository.getCategories();
    } catch (e) {
      _error = 'Gagal memuat kategori';
    } finally {
      _isCategoriesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCategory(String name) async {
    _isMutationLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createCategory(name);
      _isMutationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _isMutationLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(int id, String name) async {
    _isMutationLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateCategory(id, name);
      _isMutationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _isMutationLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    _isMutationLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteCategory(id);
      _isMutationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _isMutationLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadOrders({bool refresh = false, String? paymentStatus}) async {
    if (refresh) {
      _currentOrderPage = 1;
      _orders = [];
    }

    _isOrdersLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getOrders(
        page: _currentOrderPage,
        paymentStatus: paymentStatus,
      );
      _orders.addAll(data['orders'] as List<Order>);
      _currentOrderPage = data['current_page'] as int;
      _lastOrderPage = data['last_page'] as int;
    } catch (e) {
      _error = 'Gagal memuat pesanan';
    } finally {
      _isOrdersLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreOrders() async {
    if (_isOrdersLoading || !hasMoreOrders) return;
    _currentOrderPage++;
    await loadOrders();
  }

  Future<void> loadOrderDetail(int id) async {
    _isOrderDetailLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await _repository.getOrderDetail(id);
    } catch (e) {
      _error = 'Gagal memuat detail pesanan';
    } finally {
      _isOrderDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePaymentStatus(int orderId, String status) async {
    _isMutationLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updatePaymentStatus(orderId, status);
      _selectedOrder = null;
      _isMutationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _extractMessage(e);
      _isMutationLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
  }
}
