import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/product.dart';
import '../../providers/admin_provider.dart';
import 'product_form_screen.dart';

class AdminProductListScreen extends StatefulWidget {
  const AdminProductListScreen({super.key});

  @override
  State<AdminProductListScreen> createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  final _searchController = TextEditingController();
  String? _searchQuery;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadProducts(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminProvider>().loadMoreProducts();
    }
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
    context.read<AdminProvider>().loadProducts(refresh: true, search: _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kelola Produk'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AdminProductFormScreen()),
          );
          if (result == true && context.mounted) {
            context.read<AdminProvider>().loadProducts(refresh: true);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = null);
                          context.read<AdminProvider>().loadProducts(refresh: true);
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, _) {
                if (adminProvider.isProductsLoading && adminProvider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (adminProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.grey),
                        const SizedBox(height: 16),
                        Text('Belum ada produk', style: TextStyle(color: AppTheme.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => adminProvider.loadProducts(refresh: true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: adminProvider.products.length + (adminProvider.hasMoreProducts ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == adminProvider.products.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final product = adminProvider.products[index];
                      return _ProductItem(
                        product: product,
                        onEdit: () async {
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => AdminProductFormScreen(product: product),
                            ),
                          );
                          if (result == true && context.mounted) {
                            adminProvider.loadProducts(refresh: true);
                          }
                        },
                        onDelete: () => _deleteProduct(product),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await context.read<AdminProvider>().deleteProduct(product.id);
      if (success && context.mounted) {
        context.read<AdminProvider>().loadProducts(refresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil dihapus')),
          );
        }
      }
    }
  }
}

class _ProductItem extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductItem({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 64,
                    height: 64,
                    color: AppTheme.lightGrey,
                    child: Icon(Icons.image, color: AppTheme.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.priceFormatted,
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          product.category.name,
                          style: TextStyle(color: AppTheme.grey, fontSize: 12),
                        ),
                        if (product.isBestSeller) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('Best', style: TextStyle(fontSize: 10, color: AppTheme.warning)),
                          ),
                        ],
                        if (product.isNewArrival) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('New', style: TextStyle(fontSize: 10, color: AppTheme.success)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
