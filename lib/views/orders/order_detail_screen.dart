import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/order_provider.dart';
import '../../widgets/loading_widget.dart';
import '../home/home_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final bool isFromCheckout;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.isFromCheckout = false,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrderDetail(widget.orderId);
    });
  }

  Future<void> _cancelOrder(int orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final success = await context.read<OrderProvider>().cancelOrder(orderId);
    if (success && mounted) {
      context.read<OrderProvider>().loadOrderDetail(orderId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        automaticallyImplyLeading: !widget.isFromCheckout,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isDetailLoading) {
            return const LoadingWidget();
          }

          final order = orderProvider.selectedOrder;
          if (order == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(orderProvider.error ?? 'Pesanan tidak ditemukan'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderProvider.loadOrderDetail(widget.orderId),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (widget.isFromCheckout)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pesanan Berhasil Dibuat!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            const SizedBox(height: 4),
                            Text(
                              'Silakan lakukan pembayaran sesuai instruksi di bawah.',
                              style: TextStyle(fontSize: 12, color: Colors.green.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.isFromCheckout) const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(order.orderNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: order.paymentStatus == 'paid' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.paymentStatusLabel,
                              style: TextStyle(color: order.paymentStatus == 'paid' ? Colors.green : Colors.orange, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(order.createdAtFormatted, style: TextStyle(color: AppTheme.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Informasi Pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Nama', order.shippingName),
                      _infoRow('Telepon', order.shippingPhone),
                      _infoRow('Email', order.shippingEmail),
                      _infoRow('Alamat', '${order.shippingAddress}\n${order.shippingDistrict}, ${order.shippingCity}\n${order.shippingProvince}, ${order.shippingPostalCode}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Item Pesanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (order.items != null)
                        ...order.items!.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('${item.quantity} x ${item.priceFormatted}', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Text(item.subtotalFormatted, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.accent)),
                          Text(order.totalFormatted, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow('Metode', order.paymentMethodLabel),
                      _infoRow('Status', order.paymentStatusLabel),
                    ],
                  ),
                ),
              ),
              if (order.paymentStatus == 'pending') ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () => _cancelOrder(order.id),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Batalkan Pesanan'),
                  ),
                ),
              ],
              if (order.paymentInstructions != null) ...[
                const SizedBox(height: 16),
                _buildPaymentInstructions(order.paymentInstructions!),
              ],
              const SizedBox(height: 24),
              if (widget.isFromCheckout)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => route.isFirst,
                      );
                    },
                    child: const Text('Kembali ke Beranda'),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: AppTheme.grey, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildPaymentInstructions(Map<String, dynamic> instructions) {
    final method = instructions['method'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Instruksi Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.accent)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(instructions['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (instructions['note'] != null) ...[
                  const SizedBox(height: 8),
                  Text(instructions['note'] as String, style: TextStyle(color: AppTheme.accent.withValues(alpha: 0.7))),
                ],
                if (method == 'bank_transfer' && instructions['banks'] != null) ...[
                  const SizedBox(height: 12),
                  ...(instructions['banks'] as List).map(
                    (bank) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance, size: 20, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bank['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: bank['number'] as String));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Nomor rekening disalin!'), duration: Duration(seconds: 2)),
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(bank['number'] as String, style: TextStyle(color: AppTheme.grey), overflow: TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.copy, size: 14, color: AppTheme.primary),
                                    ],
                                  ),
                                ),
                                Text('a.n. ${bank['holder'] as String}', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (method == 'ewallet' && instructions['providers'] != null) ...[
                  const SizedBox(height: 12),
                  ...(instructions['providers'] as List).map(
                    (provider) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(Icons.phone_android, size: 20, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(provider['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: provider['number'] as String));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Nomor e-wallet disalin!'), duration: Duration(seconds: 2)),
                                      );
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(provider['number'] as String, style: TextStyle(color: AppTheme.grey), overflow: TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.copy, size: 14, color: AppTheme.primary),
                                    ],
                                  ),
                                ),
                                Text('a.n. ${provider['holder'] as String}', style: TextStyle(color: AppTheme.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final whatsapp = instructions['whatsapp_number'] as String?;
                      final message = instructions['whatsapp_message'] as String?;
                      if (whatsapp != null) {
                        launchUrl(
                          Uri.parse('https://wa.me/$whatsapp?text=${Uri.encodeComponent(message ?? '')}'),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Konfirmasi via WhatsApp'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
