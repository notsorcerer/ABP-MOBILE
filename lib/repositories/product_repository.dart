import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _api;

  ProductRepository(this._api);

  Future<Map<String, dynamic>> getHomeData() async {
    final response = await _api.get('products/home');
    final data = response.data['data'];

    final bestSellers = (data['best_sellers'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    final newArrivals = (data['new_arrivals'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    final categories = (data['categories'] as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();

    return {
      'best_sellers': bestSellers,
      'new_arrivals': newArrivals,
      'categories': categories,
    };
  }

  Future<Map<String, dynamic>> getProducts({
    String? categorySlug,
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (categorySlug != null) {
      queryParams['category'] = categorySlug;
    }

    final response = await _api.get('products', queryParameters: queryParams);
    final data = response.data['data'] as List;
    final meta = response.data['meta'];

    final products = data
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();

    return {
      'products': products,
      'current_page': meta['current_page'],
      'last_page': meta['last_page'],
      'total': meta['total'],
    };
  }

  Future<Product> getProductDetail(int id) async {
    final response = await _api.get('products/$id');
    return Product.fromJson(response.data['data']);
  }
}
