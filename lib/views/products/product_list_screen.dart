import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String? categorySlug;
  final String? categoryName;

  const ProductListScreen({
    super.key,
    this.categorySlug,
    this.categoryName,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(
        categorySlug: widget.categorySlug,
        refresh: true,
      );
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMoreProducts(
        categorySlug: widget.categorySlug,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = value);
      context.read<ProductProvider>().loadProducts(
        categorySlug: widget.categorySlug,
        search: value.isNotEmpty ? value : null,
        refresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'Semua Produk'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search, color: AppTheme.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                if (productProvider.isProductListLoading && productProvider.products.isEmpty) {
                  return const LoadingWidget();
                }

                if (productProvider.error != null && productProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(productProvider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            productProvider.loadProducts(
                              categorySlug: widget.categorySlug,
                              search: _searchQuery.isNotEmpty ? _searchQuery : null,
                              refresh: true,
                            );
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => productProvider.loadProducts(
                    categorySlug: widget.categorySlug,
                    search: _searchQuery.isNotEmpty ? _searchQuery : null,
                    refresh: true,
                  ),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: productProvider.products.length + (productProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == productProvider.products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final product = productProvider.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
                          );
                        },
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
}
