import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/errors/app_exception.dart';
import '../../orders/models/order_model.dart';
import '../models/admin_models.dart';

class AdminService {
  final supa.SupabaseClient? _client;

  AdminService({supa.SupabaseClient? client})
    : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengecek apakah user saat ini adalah admin.
  Future<bool> isCurrentUserAdmin() async {
    final client = _client;
    if (client == null) return false;

    final userId = client.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final response = await client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] == 'admin';
    } catch (e) {
      debugPrint('Notice isCurrentUserAdmin: $e');
      return false;
    }
  }

  // ─── LAPORAN PRODUK ─────────────────────────────────────────

  /// Membuat laporan produk baru.
  Future<ProductReportModel> submitReport({
    required String reporterId,
    required String productId,
    required String reason,
    String? description,
  }) async {
    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    try {
      final payload = {
        'product_id': productId,
        'reporter_id': reporterId,
        'reason': reason,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      };

      final response = await client
          .from('product_reports')
          .insert(payload)
          .select()
          .single();

      return ProductReportModel.fromJson(response);
    } catch (e) {
      debugPrint('Notice submitReport: $e');
      throw const DatabaseException(
        'Gagal mengirim laporan. Silakan coba lagi.',
      );
    }
  }

  /// Mengambil semua laporan produk (admin only).
  Future<List<ProductReportModel>> fetchAllReports({
    String? statusFilter,
  }) async {
    final client = _client;
    if (client == null) return [];

    try {
      var query = client
          .from('product_reports')
          .select(
            '*, products(name), profiles!product_reports_reporter_id_fkey(display_name)',
          );

      if (statusFilter != null && statusFilter != 'Semua') {
        query = query.eq('status', statusFilter);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map(
            (json) => ProductReportModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Notice fetchAllReports: $e');
      return [];
    }
  }

  // ─── TINDAKAN MODERASI ──────────────────────────────────────

  /// Nonaktifkan produk yang dilaporkan.
  Future<bool> deactivateProduct({
    required String adminId,
    required String reportId,
    required String productId,
    String? notes,
  }) async {
    final client = _client;
    if (client == null) return false;

    try {
      // Nonaktifkan produk (soft delete)
      await client
          .from('products')
          .update({
            'is_published': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productId);

      // Update status laporan
      await client
          .from('product_reports')
          .update({
            'status': 'reviewed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);

      // Catat tindakan
      await client.from('moderation_actions').insert({
        'report_id': reportId,
        'admin_id': adminId,
        'product_id': productId,
        'action_type': 'deactivate_product',
        'notes': notes ?? 'Produk dinonaktifkan berdasarkan laporan.',
      });

      return true;
    } catch (e) {
      debugPrint('Notice deactivateProduct: $e');
      return false;
    }
  }

  /// Beri peringatan ke penjual.
  Future<bool> warnSeller({
    required String adminId,
    required String reportId,
    required String productId,
    String? notes,
  }) async {
    final client = _client;
    if (client == null) return false;

    try {
      // Update status laporan
      await client
          .from('product_reports')
          .update({
            'status': 'reviewed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);

      // Catat tindakan
      await client.from('moderation_actions').insert({
        'report_id': reportId,
        'admin_id': adminId,
        'product_id': productId,
        'action_type': 'warn_seller',
        'notes': notes ?? 'Peringatan diberikan kepada penjual.',
      });

      return true;
    } catch (e) {
      debugPrint('Notice warnSeller: $e');
      return false;
    }
  }

  /// Abaikan laporan (produk tetap aktif).
  Future<bool> dismissReport({
    required String adminId,
    required String reportId,
    String? productId,
    String? notes,
  }) async {
    final client = _client;
    if (client == null) return false;

    try {
      await client
          .from('product_reports')
          .update({
            'status': 'dismissed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reportId);

      await client.from('moderation_actions').insert({
        'report_id': reportId,
        'admin_id': adminId,
        'product_id': productId,
        'action_type': 'dismiss_report',
        'notes': notes ?? 'Laporan diabaikan, produk tetap aktif.',
      });

      return true;
    } catch (e) {
      debugPrint('Notice dismissReport: $e');
      return false;
    }
  }

  // ─── DATA TRANSAKSI (KF-21) ────────────────────────────────

  /// Mengambil semua pesanan untuk admin dashboard.
  Future<List<OrderModel>> fetchAllOrders({
    String? statusFilter,
    int limit = 50,
  }) async {
    final client = _client;
    if (client == null) return [];

    try {
      var query = client.from('orders').select('*, order_items(*)');

      if (statusFilter != null && statusFilter != 'Semua') {
        query = query.eq('status', statusFilter);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Notice fetchAllOrders: $e');
      return [];
    }
  }

  /// Menghitung ringkasan transaksi untuk dashboard admin.
  Future<Map<String, dynamic>> getTransactionSummary() async {
    final client = _client;
    if (client == null) {
      return {'total_orders': 0, 'total_revenue': 0, 'pending_reports': 0};
    }

    try {
      final ordersResponse = await client
          .from('orders')
          .select('total, status');
      final orders = ordersResponse as List<dynamic>;

      int totalOrders = orders.length;
      int totalRevenue = 0;
      int paidOrders = 0;
      for (final o in orders) {
        final status = o['status'] as String? ?? '';
        if (status != 'cancelled' && status != 'pending_payment') {
          totalRevenue += (o['total'] as int? ?? 0);
          paidOrders++;
        }
      }

      final reportsResponse = await client
          .from('product_reports')
          .select('id')
          .eq('status', 'pending');
      final pendingReports = (reportsResponse as List<dynamic>).length;

      return {
        'total_orders': totalOrders,
        'paid_orders': paidOrders,
        'total_revenue': totalRevenue,
        'pending_reports': pendingReports,
      };
    } catch (e) {
      debugPrint('Notice getTransactionSummary: $e');
      return {'total_orders': 0, 'total_revenue': 0, 'pending_reports': 0};
    }
  }
}
