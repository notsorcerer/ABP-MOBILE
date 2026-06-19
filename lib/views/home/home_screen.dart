import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/order_list_screen.dart';
import '../products/product_detail_screen.dart';
import '../products/product_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadHomeData();
      context.read<CartProvider>().loadCart();
    });
  }

  void _openCart() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.water_drop, color: AppTheme.primary, size: 24),
            const SizedBox(width: 8),
            const Text('LiquidPedia'),
          ],
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                children: [
                  IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: _openCart),
                  if (cart.totalItems > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          '${cart.totalItems}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isHomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await productProvider.loadHomeData();
              if (context.mounted) context.read<CartProvider>().loadCart();
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                _HeroSection(onSearch: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListScreen()));
                }),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Kategori', actionLabel: null, onAction: null),
                const SizedBox(height: 12),
                _CategoryCards(categories: productProvider.categories),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Best Seller',
                  actionLabel: 'Lihat Semua',
                  onAction: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListScreen()));
                  },
                ),
                const SizedBox(height: 8),
                _ProductRow(products: productProvider.bestSellers),
                const SizedBox(height: 24),
                _PromoBanner(),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'New Arrival',
                  actionLabel: 'Lihat Semua',
                  onAction: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListScreen()));
                  },
                ),
                const SizedBox(height: 8),
                _ProductRow(products: productProvider.newArrivals),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrderListScreen()));
            case 2:
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final VoidCallback onSearch;
  const _HeroSection({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D1616), Color(0xFF8E1616), Color(0xFFD84040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Welcome to LiquidPedia', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Find Your Perfect Vibe',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Temukan liquid dan device vape terbaik untuk pengalaman vaping terbaikmu',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: onSearch,
                    child: const Text('Lihat Produk', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: () {},
                    child: const Text('Best Seller', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatBadge(label: '50+ Varian Liquid'),
              const SizedBox(width: 12),
              _StatBadge(label: '20+ Device Vape'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  const _StatBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accent, letterSpacing: -0.3)),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class _CategoryCards extends StatelessWidget {
  final List<Category> categories;
  const _CategoryCards({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isVape = category.slug == 'vape';
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ProductListScreen(categorySlug: category.slug, categoryName: category.name),
              ));
            },
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isVape
                      ? [const Color(0xFF1D1616), const Color(0xFF8E1616)]
                      : [const Color(0xFFD84040), const Color(0xFF8E1616)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: isVape ? const Color(0xFF1D1616).withValues(alpha: 0.2) : AppTheme.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${category.productsCount} produk', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final List<Product> products;
  const _ProductRow({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)));
            },
            addToCartButton: AddToCartMiniButton(product: product),
          );
        },
      ),
    );
  }
}

class AddToCartMiniButton extends StatelessWidget {
  final Product product;
  const AddToCartMiniButton({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final auth = context.read<AuthProvider>();
        if (!auth.isLoggedIn) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
          return;
        }
        context.read<CartProvider>().addToCart(product.id, quantity: 1).then((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} ditambahkan ke cart'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 4)],
        ),
        child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD84040), Color(0xFF8E1616), Color(0xFF1D1616)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('FIND FLAVORS', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                const Text('THAT MATCH YOUR VIBE', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.accent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductListScreen()));
                    },
                    child: const Text('Explore Now', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          const Text('💨', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }
}
