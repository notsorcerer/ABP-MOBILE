class CartItem {
  final int productId;
  final String name;
  final double price;
  final String priceFormatted;
  final String imageUrl;
  int quantity;
  final double subtotal;
  final String subtotalFormatted;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.priceFormatted,
    required this.imageUrl,
    required this.quantity,
    required this.subtotal,
    required this.subtotalFormatted,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      priceFormatted: json['price_formatted'] as String,
      imageUrl: json['image_url'] as String,
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      subtotalFormatted: json['subtotal_formatted'] as String,
    );
  }
}
