import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/admin_provider.dart';
import 'order_detail_screen.dart';

class AdminOrderListScreen extends StatefulWidget {
  const AdminOrderListScreen({super.key});

  @override
  State<AdminOrderListScreen> createState() => _AdminOrderListScreenState();
}

class _AdminOrderListScreenState extends State<AdminOrderListScreen> {
  String? _statusFilter;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadOrders(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminProvider>().loadMoreOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kelola Pesanan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    selected: _statusFilter == null,
                    onSelected: () => _setFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Menunggu',
                    color: AppTheme.warning,
                    selected: _statusFilter == 'pending',
                    onSelected: () => _setFilter('pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Lunas',
                    color: AppTheme.success,
                    selected: _statusFilter == 'paid',
                    onSelected: () => _setFilter('paid'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Dibatalkan',
                    color: Colors.red,
                    selected: _statusFilter == 'cancelled',
                    onSelected: () => _setFilter('cancelled'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, adminProvider, _) {
                if (adminProvider.isOrdersLoading && adminProvider.orders.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (adminProvider.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.grey),
                        const SizedBox(height: 16),
                        Text('Tidak ada pesanan', style: TextStyle(color: AppTheme.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => adminProvider.loadOrders(refresh: true, paymentStatus: _statusFilter),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: adminProvider.orders.length + (adminProvider.hasMoreOrders ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == adminProvider.orders.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final order = adminProvider.orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AdminOrderDetailScreen(orderId: order.id),
                              ),
                            );
                            if (context.mounted) {
                              adminProvider.loadOrders(refresh: true);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.orderNumber,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        order.shippingName,
                                        style: TextStyle(color: AppTheme.grey, fontSize: 13),
                                      ),
                                      Text(
                                        order.createdAtFormatted,
                                        style: TextStyle(color: AppTheme.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      order.totalFormatted,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusColor(order.paymentStatus).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        order.paymentStatusLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: _statusColor(order.paymentStatus),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppTheme.warning;
      case 'paid': return AppTheme.success;
      case 'cancelled': return Colors.red;
      default: return AppTheme.grey;
    }
  }

  void _setFilter(String? status) {
    setState(() => _statusFilter = status);
    context.read<AdminProvider>().loadOrders(refresh: true, paymentStatus: status);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: (color ?? AppTheme.primary).withValues(alpha: 0.2),
      checkmarkColor: color ?? AppTheme.primary,
    );
  }
}
