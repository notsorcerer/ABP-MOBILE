import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/location_picker.dart';
import '../../widgets/payment_method_picker.dart';
import '../orders/order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController(text: 'Indonesia');
  final _provinceController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _addressController = TextEditingController();

  double? _latitude;
  double? _longitude;
  String? _paymentMethod;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _provinceController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _zipcodeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih lokasi pengiriman')),
      );
      return;
    }

    if (_paymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih metode pembayaran')),
      );
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.createOrder(
      name: _nameController.text.trim(),
      country: _countryController.text.trim(),
      province: _provinceController.text.trim(),
      city: _cityController.text.trim(),
      district: _districtController.text.trim(),
      zipcode: _zipcodeController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      paymentMethod: _paymentMethod!,
    );

    if (success && mounted) {
      await context.read<CartProvider>().loadCart();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => OrderDetailScreen(
            orderId: orderProvider.selectedOrder?.id ?? 0,
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Pengiriman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                    validator: (v) => v?.trim().isEmpty == true
                        ? 'Nama tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'No. Telepon',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) => v?.trim().isEmpty == true
                        ? 'No. telepon tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => v?.trim().isEmpty == true
                        ? 'Email tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Negara',
                            prefixIcon: Icon(Icons.public),
                          ),
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'Negara tidak boleh kosong'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _provinceController,
                          decoration: const InputDecoration(
                            labelText: 'Provinsi',
                            prefixIcon: Icon(Icons.map_outlined),
                          ),
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'Provinsi tidak boleh kosong'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Kota',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'Kota tidak boleh kosong'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _districtController,
                          decoration: const InputDecoration(
                            labelText: 'Kecamatan',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) => v?.trim().isEmpty == true
                              ? 'Kecamatan tidak boleh kosong'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _zipcodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Kode Pos',
                      prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                    ),
                    validator: (v) => v?.trim().isEmpty == true
                        ? 'Kode Pos tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Lengkap',
                      prefixIcon: Icon(Icons.home_outlined),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => v?.trim().isEmpty == true
                        ? 'Alamat tidak boleh kosong'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Pilih Lokasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LocationPicker(
                    onLocationChanged: (lat, lng) {
                      _latitude = lat;
                      _longitude = lng;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  PaymentMethodPicker(
                    onChanged: (method) {
                      _paymentMethod = method;
                    },
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Item',
                              style: TextStyle(color: AppTheme.grey),
                            ),
                            Text(
                              '${cartProvider.totalItems} item',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Harga',
                              style: TextStyle(color: AppTheme.grey),
                            ),
                            Text(
                              cartProvider.totalFormatted,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (orderProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        orderProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: orderProvider.isCreatingOrder
                          ? null
                          : _submitOrder,
                      child: orderProvider.isCreatingOrder
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Buat Pesanan'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
