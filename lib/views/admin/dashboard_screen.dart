import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/admin_provider.dart';
import 'category_list_screen.dart';
import 'order_list_screen.dart';
import 'product_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = adminProvider.dashboardStats;
          if (stats == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.grey),
                  const SizedBox(height: 16),
                  Text(adminProvider.error ?? 'Gagal memuat dashboard'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.loadDashboard(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => adminProvider.loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _StatCard(
                      icon: Icons.inventory_2,
                      label: 'Produk',
                      value: stats.totalProducts.toString(),
                      color: AppTheme.primary,
                    ),
                    _StatCard(
                      icon: Icons.category,
                      label: 'Kategori',
                      value: stats.totalCategories.toString(),
                      color: const Color(0xFF2196F3),
                    ),
                    _StatCard(
                      icon: Icons.pending_actions,
                      label: 'Pesanan Baru',
                      value: stats.pendingOrders.toString(),
                      color: AppTheme.warning,
                    ),
                    _StatCard(
                      icon: Icons.check_circle,
                      label: 'Lunas',
                      value: stats.paidOrders.toString(),
                      color: AppTheme.success,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Produk per Kategori',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...stats.productsPerCategory.map((cat) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(cat.name),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${cat.productsCount}',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.inventory_2,
                        label: 'Kelola Produk',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminProductListScreen()),
                        ),
                      ),
                      const Divider(height: 0),
                      _MenuTile(
                        icon: Icons.category,
                        label: 'Kelola Kategori',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminCategoryListScreen()),
                        ),
                      ),
                      const Divider(height: 0),
                      _MenuTile(
                        icon: Icons.receipt_long,
                        label: 'Kelola Pesanan',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminOrderListScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(color: AppTheme.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
