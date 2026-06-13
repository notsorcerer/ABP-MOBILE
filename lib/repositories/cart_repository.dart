import '../models/cart_item.dart';
import '../services/api_service.dart';

class CartRepository {
  final ApiService _api;

  CartRepository(this._api);

  Future<Map<String, dynamic>> getCart() async {
    final response = await _api.get('cart');
    final data = response.data['data'];

    final items = (data['items'] as List)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return {
      'items': items,
      'total': (data['total'] as num).toDouble(),
      'total_formatted': data['total_formatted'] as String,
      'total_items': data['total_items'] as int,
    };
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    await _api.post('cart/$productId', data: {'quantity': quantity});
  }

  Future<void> updateCartItem(int productId, int quantity) async {
    await _api.put('cart/$productId', data: {'quantity': quantity});
  }

  Future<void> removeFromCart(int productId) async {
    await _api.delete('cart/$productId');
  }
}
