import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/admin_provider.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadOrderDetail(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isOrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = adminProvider.selectedOrder;
          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.grey),
                  const SizedBox(height: 16),
                  Text(adminProvider.error ?? 'Pesanan tidak ditemukan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.loadOrderDetail(widget.orderId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final canUpdate = order.paymentStatus == 'pending';

          return RefreshIndicator(
            onRefresh: () => adminProvider.loadOrderDetail(widget.orderId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.orderNumber,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(order.paymentStatus).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.paymentStatusLabel,
                                style: TextStyle(
                                  color: _statusColor(order.paymentStatus),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dibuat: ${order.createdAtFormatted}',
                          style: TextStyle(color: AppTheme.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Customer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Nama', value: order.shippingName),
                        _InfoRow(label: 'Telepon', value: order.shippingPhone),
                        _InfoRow(label: 'Email', value: order.shippingEmail),
                        const Divider(height: 16),
                        Text(
                          'Alamat Pengiriman',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Negara', value: order.shippingCountry),
                        _InfoRow(label: 'Provinsi', value: order.shippingProvince),
                        _InfoRow(label: 'Kota', value: order.shippingCity),
                        _InfoRow(label: 'Kecamatan', value: order.shippingDistrict),
                        _InfoRow(label: 'Kode Pos', value: order.shippingPostalCode),
                        _InfoRow(label: 'Alamat', value: order.shippingAddress),
                        if (order.shippingLatitude != null && order.shippingLongitude != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Koordinat: ${order.shippingLatitude}, ${order.shippingLongitude}',
                            style: TextStyle(color: AppTheme.grey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item Pesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (order.items != null)
                          ...order.items!.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                      Text(
                                        '${item.quantity} x ${item.priceFormatted}',
                                        style: TextStyle(color: AppTheme.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.subtotalFormatted,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                              ),
                            ),
                            Text(
                              order.totalFormatted,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'Metode', value: order.paymentMethodLabel),
                        _InfoRow(label: 'Status', value: order.paymentStatusLabel),
                      ],
                    ),
                  ),
                ),
                if (canUpdate) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                      onPressed: _isProcessing ? null : () => _updateStatus('paid'),
                      child: _isProcessing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Tandai Lunas'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: _isProcessing ? null : () => _updateStatus('cancelled'),
                      child: const Text('Batalkan Pesanan'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                if (adminProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      adminProvider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          );
        },
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

  Future<void> _updateStatus(String status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'paid' ? 'Tandai Lunas' : 'Batalkan Pesanan'),
        content: Text(status == 'paid'
            ? 'Yakin ingin menandai pesanan ini sebagai lunas?'
            : 'Yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: status == 'paid' ? AppTheme.success : Colors.red,
            ),
            child: Text(status == 'paid' ? 'Ya, Lunas' : 'Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isProcessing = true);
      final success = await context.read<AdminProvider>().updatePaymentStatus(widget.orderId, status);
      setState(() => _isProcessing = false);

      if (success && mounted) {
        context.read<AdminProvider>().loadOrderDetail(widget.orderId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'paid' ? 'Pesanan ditandai lunas' : 'Pesanan dibatalkan')),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: AppTheme.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
