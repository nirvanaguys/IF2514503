import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../services/seller_service.dart';

class SellerOrdersScreen extends StatefulWidget {
  final String sellerId;

  const SellerOrdersScreen({super.key, required this.sellerId});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  final _sellerService = SellerService();
  List<Map<String, dynamic>> _orderItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final items = await _sellerService.fetchSellerOrders(widget.sellerId);
    if (mounted) {
      setState(() {
        _orderItems = items;
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending_payment':
        return 'Menunggu Bayar';
      case 'paid':
        return 'Sudah Dibayar';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending_payment':
        return const Color(0xFF9A6700);
      case 'paid':
        return const Color(0xFF1565C0);
      case 'processing':
        return const Color(0xFF6A1B9A);
      case 'shipped':
        return const Color(0xFF2E7D32);
      case 'delivered':
        return AppTheme.forest;
      case 'cancelled':
        return const Color(0xFFC62828);
      default:
        return AppTheme.mutedText;
    }
  }

  /// Menentukan aksi status berikutnya yang dapat dilakukan penjual.
  String? _nextStatusAction(String currentStatus) {
    switch (currentStatus) {
      case 'paid':
        return 'processing';
      case 'processing':
        return 'shipped';
      default:
        return null;
    }
  }

  String _nextStatusLabel(String nextStatus) {
    switch (nextStatus) {
      case 'processing':
        return 'Proses Pesanan';
      case 'shipped':
        return 'Tandai Dikirim';
      default:
        return nextStatus;
    }
  }

  Future<void> _handleUpdateStatus(String orderId, String newStatus) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Perbarui Status Pesanan?'),
        content: Text(
          'Status pesanan akan diubah menjadi "${_statusLabel(newStatus)}".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forest,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await _sellerService.updateOrderStatus(
      orderId,
      widget.sellerId,
      newStatus,
    );

    if (!mounted) return;

    if (success) {
      _showMessage('Status pesanan berhasil diperbarui.');
      _loadOrders();
    } else {
      _showMessage('Gagal memperbarui status pesanan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan order items berdasarkan order_id
    final Map<String, List<Map<String, dynamic>>> groupedOrders = {};
    for (final item in _orderItems) {
      final orderData = item['orders'] as Map<String, dynamic>?;
      if (orderData == null) continue;
      final orderId = orderData['id'] as String;
      groupedOrders.putIfAbsent(orderId, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Pesanan Masuk',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : groupedOrders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.softGreen,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.inbox_outlined,
                        size: 40,
                        color: AppTheme.forest,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Pesanan Masuk',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101F16),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Pesanan dari pembeli yang membeli produk Anda akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: groupedOrders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final orderId = groupedOrders.keys.elementAt(index);
                  final items = groupedOrders[orderId]!;
                  final orderData =
                      items.first['orders'] as Map<String, dynamic>;
                  final status = orderData['status'] as String? ?? '';
                  final total = orderData['total'] as int? ?? 0;
                  final nextAction = _nextStatusAction(status);

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Order ID + Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pesanan #${orderId.length > 12 ? orderId.substring(orderId.length - 8) : orderId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(status)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _statusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Item list
                          ...items.map((item) {
                            final productName =
                                item['product_name_snapshot'] as String? ??
                                'Produk';
                            final qty = item['quantity'] as int? ?? 1;
                            final price = item['unit_price'] as int? ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '$productName x$qty',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatRupiah(price * qty)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const Divider(height: 16),

                          // Total & Action
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Pesanan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.mutedText,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatRupiah(total)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: AppTheme.forest,
                                    ),
                                  ),
                                ],
                              ),
                              if (nextAction != null)
                                ElevatedButton(
                                  onPressed: () =>
                                      _handleUpdateStatus(orderId, nextAction),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.forest,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _nextStatusLabel(nextAction),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatRupiah(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    final len = str.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
