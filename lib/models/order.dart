import 'order_item.dart';

class Order {
  final int id;
  final String orderNumber;
  final double total;
  final String totalFormatted;
  final String paymentMethod;
  final String paymentMethodLabel;
  final String paymentStatus;
  final String paymentStatusLabel;
  final String shippingName;
  final String shippingCountry;
  final String shippingProvince;
  final String shippingCity;
  final String shippingDistrict;
  final String shippingPostalCode;
  final String shippingAddress;
  final String shippingPhone;
  final String shippingEmail;
  final String? shippingLatitude;
  final String? shippingLongitude;
  final List<OrderItem>? items;
  final int? itemsCount;
  final String createdAt;
  final String createdAtFormatted;
  final Map<String, dynamic>? paymentInstructions;

  Order({
    required this.id,
    required this.orderNumber,
    required this.total,
    required this.totalFormatted,
    required this.paymentMethod,
    required this.paymentMethodLabel,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.shippingName,
    required this.shippingCountry,
    required this.shippingProvince,
    required this.shippingCity,
    required this.shippingDistrict,
    required this.shippingPostalCode,
    required this.shippingAddress,
    required this.shippingPhone,
    required this.shippingEmail,
    this.shippingLatitude,
    this.shippingLongitude,
    this.items,
    this.itemsCount,
    required this.createdAt,
    required this.createdAtFormatted,
    this.paymentInstructions,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      total: (json['total'] as num).toDouble(),
      totalFormatted: json['total_formatted'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentMethodLabel: json['payment_method_label'] as String,
      paymentStatus: json['payment_status'] as String,
      paymentStatusLabel: json['payment_status_label'] as String,
      shippingName: json['shipping_name'] as String,
      shippingCountry: json['shipping_country'] as String,
      shippingProvince: json['shipping_province'] as String,
      shippingCity: json['shipping_city'] as String,
      shippingDistrict: json['shipping_district'] as String,
      shippingPostalCode: json['shipping_postal_code'] as String,
      shippingAddress: json['shipping_address'] as String,
      shippingPhone: json['shipping_phone'] as String,
      shippingEmail: json['shipping_email'] as String,
      shippingLatitude: json['shipping_latitude'] as String?,
      shippingLongitude: json['shipping_longitude'] as String?,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      itemsCount: json['items_count'] as int?,
      createdAt: json['created_at'] as String,
      createdAtFormatted: json['created_at_formatted'] as String,
      paymentInstructions: json['payment_instructions'] as Map<String, dynamic>?,
    );
  }
}
