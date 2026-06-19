class DashboardStats {
  final int totalProducts;
  final int totalCategories;
  final int totalBestSellers;
  final int totalNewArrivals;
  final int totalOrders;
  final int pendingOrders;
  final int paidOrders;
  final List<CategoryStat> productsPerCategory;

  DashboardStats({
    required this.totalProducts,
    required this.totalCategories,
    required this.totalBestSellers,
    required this.totalNewArrivals,
    required this.totalOrders,
    required this.pendingOrders,
    required this.paidOrders,
    required this.productsPerCategory,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProducts: json['total_products'] as int,
      totalCategories: json['total_categories'] as int,
      totalBestSellers: json['total_best_sellers'] as int,
      totalNewArrivals: json['total_new_arrivals'] as int,
      totalOrders: json['total_orders'] as int,
      pendingOrders: json['pending_orders'] as int,
      paidOrders: json['paid_orders'] as int,
      productsPerCategory: (json['products_per_category'] as List)
          .map((e) => CategoryStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CategoryStat {
  final int id;
  final String name;
  final String slug;
  final int productsCount;

  CategoryStat({
    required this.id,
    required this.name,
    required this.slug,
    required this.productsCount,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      productsCount: json['products_count'] as int? ?? 0,
    );
  }
}
