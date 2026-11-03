import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../models/order_model.dart';

class OrderService {
  final supa.SupabaseClient? _client;
  static final List<OrderModel> _localOrders = [];

  OrderService({supa.SupabaseClient? client})
    : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil daftar pesanan pengguna dari Supabase.
  Future<List<OrderModel>> fetchOrders(
    String userId, {
    String? statusFilter,
  }) async {
    final client = _client;
    if (client != null && userId.isNotEmpty) {
      try {
        var query = client
            .from('orders')
            .select('*, order_items(*)')
            .eq('buyer_id', userId);

        if (statusFilter != null && statusFilter != 'Semua') {
          query = query.eq('status', statusFilter);
        }

        final response = await query.order('created_at', ascending: false);
        final list = (response as List<dynamic>)
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();

        _localOrders
          ..clear()
          ..addAll(list);

        return list;
      } catch (e) {
        debugPrint('Notice fetchOrders Supabase: $e');
      }
    }

    if (statusFilter != null && statusFilter != 'Semua') {
      return _localOrders.where((o) => o.status == statusFilter).toList();
    }
    return List.unmodifiable(_localOrders);
  }

  /// Menyimpan pesanan baru ke cache lokal dan Supabase.
  void addLocalOrder(OrderModel order) {
    _localOrders.insert(0, order);
  }

  /// Menghitung jumlah pesanan aktif (bukan cancelled/delivered) dari cache lokal
  /// atau Supabase.
  Future<int> countActiveOrders(String userId) async {
    final client = _client;
    if (client != null && userId.isNotEmpty) {
      try {
        final response = await client
            .from('orders')
            .select('id')
            .eq('buyer_id', userId)
            .not('status', 'in', '("cancelled","delivered")');

        return (response as List<dynamic>).length;
      } catch (e) {
        debugPrint('Notice countActiveOrders Supabase: $e');
      }
    }

    // Fallback lokal
    return _localOrders
        .where(
          (o) =>
              o.buyerId == userId &&
              o.status != 'cancelled' &&
              o.status != 'delivered',
        )
        .length;
  }

  /// Membatalkan pesanan yang berstatus pending_payment.
  Future<bool> cancelOrder(String userId, String orderId) async {
    final client = _client;
    if (client != null && userId.isNotEmpty) {
      try {
        await client
            .from('orders')
            .update({'status': 'cancelled'})
            .eq('id', orderId)
            .eq('buyer_id', userId)
            .eq('status', 'pending_payment');

        // Kembalikan stok produk yang dibatalkan
        try {
          final orderItems = await client
              .from('order_items')
              .select('product_id, quantity')
              .eq('order_id', orderId);

          for (final item in (orderItems as List<dynamic>)) {
            final productId = item['product_id'] as String?;
            final qty = item['quantity'] as int? ?? 0;
            if (productId != null && qty > 0) {
              try {
                await client.rpc(
                  'decrement_stock',
                  params: {
                    'p_product_id': productId,
                    'p_quantity': -qty, // negatif = tambah stok
                  },
                );
              } catch (_) {
                // Fallback: tambah stok langsung
                try {
                  final prod = await client
                      .from('products')
                      .select('stock')
                      .eq('id', productId)
                      .single();
                  final currentStock = prod['stock'] as int;
                  await client
                      .from('products')
                      .update({'stock': currentStock + qty})
                      .eq('id', productId);
                } catch (e) {
                  debugPrint('Notice restore stock: $e');
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Notice restore stock after cancel: $e');
        }

        // Update local cache
        final idx = _localOrders.indexWhere((o) => o.id == orderId);
        if (idx >= 0) {
          final old = _localOrders[idx];
          _localOrders[idx] = OrderModel(
            id: old.id,
            buyerId: old.buyerId,
            status: 'cancelled',
            subtotal: old.subtotal,
            shippingCost: old.shippingCost,
            total: old.total,
            shippingAddressSnapshot: old.shippingAddressSnapshot,
            paymentProvider: old.paymentProvider,
            paymentReference: old.paymentReference,
            createdAt: old.createdAt,
            items: old.items,
          );
        }

        return true;
      } catch (e) {
        debugPrint('Notice cancelOrder Supabase: $e');
        return false;
      }
    }

    // Fallback lokal
    final idx = _localOrders.indexWhere((o) => o.id == orderId);
    if (idx >= 0 && _localOrders[idx].status == 'pending_payment') {
      final old = _localOrders[idx];
      _localOrders[idx] = OrderModel(
        id: old.id,
        buyerId: old.buyerId,
        status: 'cancelled',
        subtotal: old.subtotal,
        shippingCost: old.shippingCost,
        total: old.total,
        shippingAddressSnapshot: old.shippingAddressSnapshot,
        paymentProvider: old.paymentProvider,
        paymentReference: old.paymentReference,
        createdAt: old.createdAt,
        items: old.items,
      );
      return true;
    }
    return false;
  }
}
