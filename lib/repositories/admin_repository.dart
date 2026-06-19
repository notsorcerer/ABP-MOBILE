import 'package:dio/dio.dart';
import '../models/category.dart';
import '../models/dashboard_stats.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class AdminRepository {
  final ApiService _api;

  AdminRepository(this._api);

  Future<DashboardStats> getDashboard() async {
    final response = await _api.get('admin/dashboard');
    return DashboardStats.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int perPage = 20,
    String? search,
    int? categoryId,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['category_id'] = categoryId;

    final response = await _api.get('admin/products', queryParameters: params);
    final data = response.data['data'] as List;
    final meta = response.data['meta'];
    final products = data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

    return {
      'products': products,
      'current_page': meta['current_page'],
      'last_page': meta['last_page'],
      'total': meta['total'],
    };
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imagePath,
    bool isBestSeller = false,
    bool isNewArrival = false,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'price': price.toString(),
      'category_id': categoryId,
      'is_best_seller': isBestSeller ? '1' : '0',
      'is_new_arrival': isNewArrival ? '1' : '0',
    });

    if (imagePath != null) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(imagePath, filename: imagePath.split(RegExp(r'[\\/]')).last),
      ));
    }

    final response = await _api.postMultipart('admin/products', formData: formData);
    return Product.fromJson(response.data['data']);
  }

  Future<Product> updateProduct(int id, {
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? imagePath,
    bool isBestSeller = false,
    bool isNewArrival = false,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
      'price': price.toString(),
      'category_id': categoryId,
      'is_best_seller': isBestSeller ? '1' : '0',
      'is_new_arrival': isNewArrival ? '1' : '0',
      '_method': 'PUT',
    });

    if (imagePath != null) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(imagePath, filename: imagePath.split(RegExp(r'[\\/]')).last),
      ));
    }

    final response = await _api.postMultipart('admin/products/$id', formData: formData);
    return Product.fromJson(response.data['data']);
  }

  Future<void> deleteProduct(int id) async {
    await _api.delete('admin/products/$id');
  }

  Future<List<Category>> getCategories() async {
    final response = await _api.get('admin/categories');
    final data = response.data['data'] as List;
    return data.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Category> createCategory(String name) async {
    final response = await _api.post('admin/categories', data: {'name': name});
    return Category.fromJson(response.data['data']);
  }

  Future<Category> updateCategory(int id, String name) async {
    final response = await _api.put('admin/categories/$id', data: {'name': name});
    return Category.fromJson(response.data['data']);
  }

  Future<void> deleteCategory(int id) async {
    await _api.delete('admin/categories/$id');
  }

  Future<Map<String, dynamic>> getOrders({
    int page = 1,
    int perPage = 20,
    String? paymentStatus,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (paymentStatus != null) params['payment_status'] = paymentStatus;

    final response = await _api.get('admin/orders', queryParameters: params);
    final data = response.data['data'] as List;
    final meta = response.data['meta'];
    final orders = data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();

    return {
      'orders': orders,
      'current_page': meta['current_page'],
      'last_page': meta['last_page'],
      'total': meta['total'],
    };
  }

  Future<Order> getOrderDetail(int id) async {
    final response = await _api.get('admin/orders/$id');
    return Order.fromJson(response.data['data']);
  }

  Future<void> updatePaymentStatus(int orderId, String status) async {
    await _api.put('admin/orders/$orderId/payment-status', data: {
      'payment_status': status,
    });
  }
}
