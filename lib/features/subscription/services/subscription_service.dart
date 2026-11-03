import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/errors/app_exception.dart';
import '../models/subscription_models.dart';

class SubscriptionService {
  final supa.SupabaseClient? _client;

  SubscriptionService({supa.SupabaseClient? client})
    : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil daftar paket langganan yang tersedia.
  Future<List<SubscriptionPlanModel>> fetchPlans() async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('price');

      return (response as List<dynamic>)
          .map(
            (json) =>
                SubscriptionPlanModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Notice fetchPlans: $e');
      return [];
    }
  }

  /// Mengambil langganan aktif pengguna.
  Future<UserSubscriptionModel?> fetchActiveSubscription(String userId) async {
    final client = _client;
    if (client == null) return null;

    try {
      final response = await client
          .from('user_subscriptions')
          .select('*, subscription_plans(name)')
          .eq('user_id', userId)
          .eq('status', 'active')
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('expires_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return UserSubscriptionModel.fromJson(response);
      }
    } catch (e) {
      debugPrint('Notice fetchActiveSubscription: $e');
    }
    return null;
  }

  /// Mengambil info kuota diagnosis saat ini via RPC function.
  Future<QuotaInfo> getQuotaInfo(String userId) async {
    final client = _client;
    if (client == null) return QuotaInfo.freeDefault;

    try {
      final response = await client.rpc(
        'get_quota_info',
        params: {'p_user_id': userId},
      );

      if (response is List && response.isNotEmpty) {
        return QuotaInfo.fromJson(response.first as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Notice getQuotaInfo: $e');
    }
    return QuotaInfo.freeDefault;
  }

  /// Menggunakan 1 kuota diagnosis. Mengembalikan sisa kuota,
  /// atau melempar exception jika kuota habis.
  Future<int> useQuota(String userId) async {
    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    try {
      final result = await client.rpc(
        'check_and_use_quota',
        params: {'p_user_id': userId},
      );

      final remaining = result as int? ?? -1;

      if (remaining < 0) {
        throw const ValidationException(
          'Kuota diagnosis Anda telah habis bulan ini. '
          'Upgrade ke Premium untuk kuota lebih banyak.',
        );
      }

      return remaining;
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Notice useQuota: $e');
      throw const DatabaseException(
        'Gagal memproses kuota diagnosis. Silakan coba lagi.',
      );
    }
  }

  /// Membeli/mengaktifkan langganan premium.
  /// Catatan: Pembayaran sesungguhnya belum terintegrasi (menunggu Fase 5 SRS).
  /// Saat ini membuat subscription langsung sebagai demo/sandbox.
  Future<UserSubscriptionModel> subscribe({
    required String userId,
    required SubscriptionPlanModel plan,
    String? paymentReference,
  }) async {
    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    try {
      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: plan.durationDays));

      // Nonaktifkan langganan lama jika ada
      await client
          .from('user_subscriptions')
          .update({'status': 'replaced', 'updated_at': now.toIso8601String()})
          .eq('user_id', userId)
          .eq('status', 'active');

      final payload = {
        'user_id': userId,
        'plan_id': plan.id,
        'status': 'active',
        'starts_at': now.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        // ignore: use_null_aware_elements
        if (paymentReference != null) 'payment_reference': paymentReference,
      };

      final response = await client
          .from('user_subscriptions')
          .insert(payload)
          .select('*, subscription_plans(name)')
          .single();

      return UserSubscriptionModel.fromJson(response);
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Notice subscribe: $e');
      throw const DatabaseException(
        'Gagal mengaktifkan langganan. Silakan coba lagi.',
      );
    }
  }
}
