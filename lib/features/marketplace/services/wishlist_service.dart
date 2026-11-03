import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class WishlistService {
  final supa.SupabaseClient? _client;
  static final Set<String> _localWishlistCache = {};

  WishlistService({supa.SupabaseClient? client})
      : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil kumpulan ID produk yang ada di wishlist pengguna.
  Future<Set<String>> fetchWishlistIds(String userId) async {
    final client = _client;
    if (client == null) {
      return Set.from(_localWishlistCache);
    }

    try {
      final response = await client
          .from('wishlist_items')
          .select('product_id')
          .eq('user_id', userId);

      final list = (response as List<dynamic>)
          .map((item) => item['product_id'] as String)
          .toSet();

      _localWishlistCache
        ..clear()
        ..addAll(list);

      return list;
    } catch (e) {
      debugPrint('Notice fetchWishlistIds Supabase: $e');
      return Set.from(_localWishlistCache);
    }
  }

  /// Menambahkan produk ke wishlist.
  Future<bool> addToWishlist(String userId, String productId) async {
    _localWishlistCache.add(productId);

    final client = _client;
    if (client == null) return true;

    try {
      await client.from('wishlist_items').upsert({
        'user_id': userId,
        'product_id': productId,
      });
      return true;
    } catch (e) {
      debugPrint('Notice addToWishlist Supabase: $e');
      return false;
    }
  }

  /// Menghapus produk dari wishlist.
  Future<bool> removeFromWishlist(String userId, String productId) async {
    _localWishlistCache.remove(productId);

    final client = _client;
    if (client == null) return true;

    try {
      await client
          .from('wishlist_items')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
      return true;
    } catch (e) {
      debugPrint('Notice removeFromWishlist Supabase: $e');
      return false;
    }
  }
}

