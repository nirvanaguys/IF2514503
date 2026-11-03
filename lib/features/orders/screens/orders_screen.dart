import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _orderService = OrderService();
  final _authService = AuthService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _selectedFilter = 'Semua';

  final List<String> _filters = [
    'Semua',
    'pending_payment',
    'paid',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    final list = await _orderService.fetchOrders(
      user?.id ?? 'guest_user',
      statusFilter: _selectedFilter == 'Semua' ? null : _selectedFilter,
    );
    if (mounted) {
      setState(() {
        _orders = list;
        _isLoading = false;
      });
    }
  }

  String _filterLabel(String filter) {
    switch (filter) {
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
        return 'Semua';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Pesanan Saya',
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
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(f)),
                      selected: isSelected,
                      selectedColor: AppTheme.forest,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF101F16),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      backgroundColor: AppTheme.paleGreen,
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedFilter = f);
                          _loadOrders();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
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
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: AppTheme.forest,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum Ada Pesanan',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101F16),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pesanan obat dan perlengkapan tanaman Anda akan muncul di sini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = _orders[index];

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
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      OrderDetailScreen(order: order),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Pesanan #${order.id.length > 12 ? order.id.substring(order.id.length - 8) : order.id}',
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
                                          color: AppTheme.softGreen,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          order.statusBadgeText,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.forest,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (order.items.isNotEmpty)
                                    Text(
                                      '${order.items.first.productName}${order.items.length > 1 ? ' (+${order.items.length - 1} produk lainnya)' : ''}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Pesanan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.mutedText,
                                        ),
                                      ),
                                      Text(
                                        order.formattedTotal,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: AppTheme.forest,
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
                  ),
          ),
        ],
      ),
    );
  }
}
