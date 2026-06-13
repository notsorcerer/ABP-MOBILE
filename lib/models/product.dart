class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String priceFormatted;
  final String imageUrl;
  final CategoryInfo category;
  final bool isBestSeller;
  final bool isNewArrival;
  final String createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceFormatted,
    required this.imageUrl,
    required this.category,
    required this.isBestSeller,
    required this.isNewArrival,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      priceFormatted: json['price_formatted'] as String,
      imageUrl: json['image_url'] as String,
      category: CategoryInfo.fromJson(json['category'] as Map<String, dynamic>),
      isBestSeller: json['is_best_seller'] as bool,
      isNewArrival: json['is_new_arrival'] as bool,
      createdAt: json['created_at'] as String,
    );
  }
}

class CategoryInfo {
  final int id;
  final String name;
  final String slug;

  CategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }
}
