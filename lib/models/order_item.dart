class OrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final String priceFormatted;
  final double subtotal;
  final String subtotalFormatted;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.priceFormatted,
    required this.subtotal,
    required this.subtotalFormatted,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      priceFormatted: json['price_formatted'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      subtotalFormatted: json['subtotal_formatted'] as String,
    );
  }
}
