import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/errors/app_exception.dart';
import '../models/review_model.dart';

class ReviewService {
  final supa.SupabaseClient? _client;

  ReviewService({supa.SupabaseClient? client})
    : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil semua ulasan untuk satu produk.
  Future<List<ReviewModel>> fetchProductReviews(String productId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('product_reviews')
          .select('*, profiles(display_name)')
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Notice fetchProductReviews: $e');
      return [];
    }
  }

  /// Mengecek apakah pengguna sudah memberi ulasan untuk produk di pesanan tertentu.
  Future<bool> hasReviewed({
    required String userId,
    required String productId,
    required String orderId,
  }) async {
    final client = _client;
    if (client == null) return false;

    try {
      final response = await client
          .from('product_reviews')
          .select('id')
          .eq('user_id', userId)
          .eq('product_id', productId)
          .eq('order_id', orderId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Notice hasReviewed: $e');
      return false;
    }
  }

  /// Mengecek produk mana saja dari satu pesanan yang sudah diulasi.
  Future<Set<String>> getReviewedProductIds({
    required String userId,
    required String orderId,
  }) async {
    final client = _client;
    if (client == null) return {};

    try {
      final response = await client
          .from('product_reviews')
          .select('product_id')
          .eq('user_id', userId)
          .eq('order_id', orderId);

      return (response as List<dynamic>)
          .map((r) => r['product_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('Notice getReviewedProductIds: $e');
      return {};
    }
  }

  /// Membuat ulasan baru.
  /// Validasi: pesanan harus berstatus delivered, dan belum pernah review
  /// produk ini di pesanan yang sama.
  Future<ReviewModel> submitReview({
    required String userId,
    required String productId,
    required String orderId,
    required int rating,
    String? reviewText,
  }) async {
    if (rating < 1 || rating > 5) {
      throw const ValidationException('Rating harus antara 1 sampai 5.');
    }

    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    // Validasi: pesanan harus milik user dan berstatus delivered
    try {
      final orderCheck = await client
          .from('orders')
          .select('id, status, buyer_id')
          .eq('id', orderId)
          .eq('buyer_id', userId)
          .single();

      final status = orderCheck['status'] as String? ?? '';
      if (status != 'delivered') {
        throw const ValidationException(
          'Ulasan hanya dapat diberikan untuk pesanan yang sudah selesai.',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw const ValidationException(
        'Tidak dapat memverifikasi pesanan. Pastikan pesanan sudah selesai.',
      );
    }

    // Validasi: produk harus ada di order items
    try {
      final itemCheck = await client
          .from('order_items')
          .select('id')
          .eq('order_id', orderId)
          .eq('product_id', productId)
          .maybeSingle();

      if (itemCheck == null) {
        throw const ValidationException(
          'Produk ini tidak ditemukan dalam pesanan tersebut.',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw const ValidationException(
        'Gagal memverifikasi produk dalam pesanan.',
      );
    }

    // Submit review
    try {
      final payload = {
        'product_id': productId,
        'user_id': userId,
        'order_id': orderId,
        'rating': rating,
        if (reviewText != null && reviewText.trim().isNotEmpty)
          'review_text': reviewText.trim(),
      };

      final response = await client
          .from('product_reviews')
          .insert(payload)
          .select('*, profiles(display_name)')
          .single();

      return ReviewModel.fromJson(response);
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Notice submitReview: $e');

      // Cek duplikasi
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('duplicate') || errStr.contains('unique')) {
        throw const ValidationException(
          'Anda sudah memberikan ulasan untuk produk ini pada pesanan ini.',
        );
      }

      throw const DatabaseException(
        'Gagal menyimpan ulasan. Silakan coba lagi.',
      );
    }
  }
}
