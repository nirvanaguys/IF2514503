import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _order;
  final _orderService = OrderService();
  final _authService = AuthService();
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleCancelOrder() async {
    if (_isCancelling) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text(
          'Pesanan yang sudah dibatalkan tidak dapat dikembalikan. '
          'Stok produk akan dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);

    final user = _authService.currentUser;
    final success = await _orderService.cancelOrder(user?.id ?? '', _order.id);

    if (!mounted) return;

    if (success) {
      setState(() {
        _order = OrderModel(
          id: _order.id,
          buyerId: _order.buyerId,
          status: 'cancelled',
          subtotal: _order.subtotal,
          shippingCost: _order.shippingCost,
          total: _order.total,
          shippingAddressSnapshot: _order.shippingAddressSnapshot,
          paymentProvider: _order.paymentProvider,
          paymentReference: _order.paymentReference,
          createdAt: _order.createdAt,
          items: _order.items,
        );
      });
      _showMessage('Pesanan berhasil dibatalkan.');
    } else {
      _showMessage('Gagal membatalkan pesanan. Silakan coba lagi.');
    }

    setState(() => _isCancelling = false);
  }

  @override
  Widget build(BuildContext context) {
    final address = _order.shippingAddressSnapshot;
    final recipientName = address['recipient_name'] as String? ?? 'Penerima';
    final phone = address['phone'] as String? ?? '-';
    final line = address['address_line'] as String? ?? '';
    final city = address['city'] as String? ?? '';
    final province = address['province'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101F16),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppTheme.forest,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EEE9)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.softGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppTheme.forest,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${_order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _order.statusBadgeText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.forest,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Alamat Pengiriman
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EEE9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alamat Pengiriman',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$recipientName ($phone)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$line, $city, $province',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF444444),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Daftar Item Pesanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EEE9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produk Dipesan',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ..._order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.paleGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: AppTheme.forest,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${item.quantity} x ${item.formattedPrice}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.formattedLineTotal,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rincian Pembayaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE8EEE9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Pembayaran',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal Produk',
                        style: TextStyle(color: AppTheme.mutedText),
                      ),
                      Text(
                        _order.formattedSubtotal,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ongkos Kirim',
                        style: TextStyle(color: AppTheme.mutedText),
                      ),
                      Text(
                        _order.formattedShippingCost,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _order.formattedTotal,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppTheme.forest,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Batalkan Pesanan (hanya untuk pending_payment)
            if (_order.status == 'pending_payment')
              OutlinedButton.icon(
                onPressed: _isCancelling ? null : _handleCancelOrder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC62828),
                  side: const BorderSide(color: Color(0xFFC62828)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isCancelling
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFC62828),
                        ),
                      )
                    : const Icon(Icons.cancel_outlined, size: 20),
                label: Text(
                  _isCancelling ? 'Membatalkan...' : 'Batalkan Pesanan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
