import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;

  OrderProvider(this._repository);

  List<Order> _orders = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalOrders = 0;
  bool _isLoading = false;

  Order? _selectedOrder;
  bool _isDetailLoading = false;

  bool _isCreatingOrder = false;
  Map<String, dynamic>? _lastPaymentInstructions;

  String? _error;

  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isCreatingOrder => _isCreatingOrder;
  bool get hasMore => _currentPage < _lastPage;
  int get totalOrders => _totalOrders;
  Map<String, dynamic>? get lastPaymentInstructions => _lastPaymentInstructions;
  String? get error => _error;

  Future<void> loadOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _orders = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getOrders(page: _currentPage);
      _orders.addAll(data['orders'] as List<Order>);
      _currentPage = data['current_page'] as int;
      _lastPage = data['last_page'] as int;
      _totalOrders = data['total'] as int;
    } catch (e) {
      _error = 'Gagal memuat pesanan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreOrders() async {
    if (_isLoading || !hasMore) return;
    _currentPage++;
    await loadOrders();
  }

  Future<void> loadOrderDetail(int id) async {
    _isDetailLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await _repository.getOrderDetail(id);
    } catch (e) {
      _error = 'Gagal memuat detail pesanan';
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
    required String name,
    required String country,
    required String province,
    required String city,
    required String district,
    required String zipcode,
    required String address,
    required String phone,
    required String email,
    required double latitude,
    required double longitude,
    required String paymentMethod,
  }) async {
    _isCreatingOrder = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.createOrder(
        name: name,
        country: country,
        province: province,
        city: city,
        district: district,
        zipcode: zipcode,
        address: address,
        phone: phone,
        email: email,
        latitude: latitude,
        longitude: longitude,
        paymentMethod: paymentMethod,
      );
      _selectedOrder = result['order'] as Order;
      _lastPaymentInstructions = result['payment_instructions'] as Map<String, dynamic>;
      _isCreatingOrder = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is DioException ? (e.message ?? 'Gagal membuat pesanan') : 'Gagal membuat pesanan';
      _isCreatingOrder = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    _error = null;
    notifyListeners();

    try {
      await _repository.cancelOrder(orderId);
      await loadOrders(refresh: true);
      if (_selectedOrder?.id == orderId) {
        _selectedOrder = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is DioException ? (e.message ?? 'Gagal membatalkan pesanan') : 'Gagal membatalkan pesanan';
      notifyListeners();
      return false;
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    _lastPaymentInstructions = null;
  }
}
