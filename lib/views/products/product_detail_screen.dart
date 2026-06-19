import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_widget.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Produk'),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isDetailLoading) {
            return const LoadingWidget();
          }

          final product = productProvider.selectedProduct;
          if (product == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(productProvider.error ?? 'Produk tidak ditemukan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      productProvider.loadProductDetail(widget.productId);
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.white,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(Icons.image_not_supported, size: 64, color: AppTheme.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                    const SizedBox(height: 8),
                    Text(product.priceFormatted, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                          child: Text(product.category.name, style: TextStyle(color: AppTheme.primary, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        if (product.isBestSeller)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                            child: const Text('Best Seller', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        if (product.isNewArrival) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                            child: const Text('Baru', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          _infoTableRow('Kategori', product.category.name, Icons.category_outlined),
                          const Divider(height: 20),
                          _infoTableRow('Status', product.isBestSeller ? 'Best Seller' : 'Tersedia', Icons.verified),
                          const Divider(height: 20),
                          _infoTableRow('Garansi', 'Garansi 1 Hari', Icons.shield_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                    const SizedBox(height: 8),
                    Text(product.description, style: TextStyle(color: AppTheme.accent.withValues(alpha: 0.7), height: 1.5)),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text('Jumlah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                        const Spacer(),
                        IconButton(
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppTheme.primary,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(border: Border.all(color: AppTheme.lightGrey), borderRadius: BorderRadius.circular(8)),
                          child: Text('$_quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _addToCart(product),
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Tambah ke Keranjang'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTableRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: AppTheme.grey, fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: AppTheme.accent)),
      ],
    );
  }

  Future<void> _addToCart(Product product) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final cartProvider = context.read<CartProvider>();
    await cartProvider.addToCart(product.id, quantity: _quantity);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity ${product.name} ditambahkan ke cart'),
        action: SnackBarAction(
          label: 'Lihat Cart',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
          },
        ),
      ),
    );
  }
}
