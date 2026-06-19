import '../models/order.dart';
import '../services/api_service.dart';

class OrderRepository {
  final ApiService _api;

  OrderRepository(this._api);

  Future<Map<String, dynamic>> getOrders({int page = 1, int perPage = 10}) async {
    final response = await _api.get('orders', queryParameters: {
      'page': page,
      'per_page': perPage,
    });

    final data = response.data['data'] as List;
    final meta = response.data['meta'];

    final orders = data
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();

    return {
      'orders': orders,
      'current_page': meta['current_page'],
      'last_page': meta['last_page'],
      'total': meta['total'],
    };
  }

  Future<Order> getOrderDetail(int id) async {
    final response = await _api.get('orders/$id');
    return Order.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> createOrder({
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
    final response = await _api.post('orders', data: {
      'name': name,
      'country': country,
      'province': province,
      'city': city,
      'district': district,
      'zipcode': zipcode,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'payment_method': paymentMethod,
    });

    final data = response.data['data'];
    final order = Order.fromJson(data['order']);
    final paymentInstructions = data['payment_instructions'] as Map<String, dynamic>;

    return {
      'order': order,
      'payment_instructions': paymentInstructions,
    };
  }

  Future<Map<String, dynamic>> getPaymentConfirmation(int orderId) async {
    final response = await _api.get('orders/$orderId/payment');
    return response.data['data'];
  }

  Future<void> cancelOrder(int orderId) async {
    await _api.put('orders/$orderId/cancel');
  }
}
