import 'package:flutter/material.dart';
import '../config/theme.dart';

class PaymentMethod {
  final String value;
  final String label;
  final IconData icon;
  final String subtitle;

  const PaymentMethod({
    required this.value,
    required this.label,
    required this.icon,
    required this.subtitle,
  });
}

const List<PaymentMethod> _methods = [
  PaymentMethod(
    value: 'bank_transfer',
    label: 'Transfer Bank',
    icon: Icons.account_balance,
    subtitle: 'BCA, Mandiri, BRI, BNI',
  ),
  PaymentMethod(
    value: 'ewallet',
    label: 'E-Wallet',
    icon: Icons.phone_android,
    subtitle: 'GoPay, OVO, Dana',
  ),
  PaymentMethod(
    value: 'qr_code',
    label: 'QR Code (QRIS)',
    icon: Icons.qr_code,
    subtitle: 'Scan QRIS via e-wallet/m-banking',
  ),
  PaymentMethod(
    value: 'cod',
    label: 'COD (Bayar di Tempat)',
    icon: Icons.money,
    subtitle: 'Bayar saat barang tiba',
  ),
];

class PaymentMethodPicker extends StatefulWidget {
  final void Function(String method) onChanged;

  const PaymentMethodPicker({super.key, required this.onChanged});

  @override
  State<PaymentMethodPicker> createState() => _PaymentMethodPickerState();
}

class _PaymentMethodPickerState extends State<PaymentMethodPicker> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _methods.map((method) {
        final isSelected = _selected == method.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _selected = method.value;
              });
              widget.onChanged(method.value);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.lightGrey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method.icon,
                    color: isSelected ? AppTheme.primary : AppTheme.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.label,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.accent,
                          ),
                        ),
                        Text(
                          method.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppTheme.primary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
