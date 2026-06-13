import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _repository;

  CartProvider(this._repository);

  List<CartItem> _items = [];
  double _total = 0;
  String _totalFormatted = 'Rp0';
  int _totalItems = 0;
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  double get total => _total;
  String get totalFormatted => _totalFormatted;
  int get totalItems => _totalItems;
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getCart();
      _items = data['items'] as List<CartItem>;
      _total = data['total'] as double;
      _totalFormatted = data['total_formatted'] as String;
      _totalItems = data['total_items'] as int;
    } catch (e) {
      _error = 'Gagal memuat cart';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    try {
      await _repository.addToCart(productId, quantity: quantity);
      await loadCart();
    } catch (e) {
      _error = 'Gagal menambahkan ke cart';
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      await _repository.updateCartItem(productId, quantity);
      await loadCart();
    } catch (e) {
      _error = 'Gagal memperbarui cart';
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      await _repository.removeFromCart(productId);
      await loadCart();
    } catch (e) {
      _error = 'Gagal menghapus dari cart';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
