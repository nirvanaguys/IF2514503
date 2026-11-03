import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../marketplace/models/product_model.dart';
import '../models/cart_item_model.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService({supa.SupabaseClient? client}) {
    if (client != null) {
      _instance._client = client;
    }
    return _instance;
  }

  CartService._internal() {
    _client = _resolveClient();
  }

  supa.SupabaseClient? _client;

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  final List<CartItemModel> _localItems = [];
  final ValueNotifier<int> cartCountNotifier = ValueNotifier<int>(0);

  List<CartItemModel> get items => List.unmodifiable(_localItems);

  int get totalAmount =>
      _localItems.fold<int>(0, (sum, item) => sum + item.subtotal);

  String get formattedTotalAmount {
    final str = totalAmount.toString();
    final buffer = StringBuffer('Rp ');
    final len = str.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _updateNotifier() {
    final totalCount =
        _localItems.fold<int>(0, (sum, item) => sum + item.quantity);
    cartCountNotifier.value = totalCount;
  }

  /// Mengambil keranjang dari database Supabase (atau memori jika belum login/offline).
  Future<List<CartItemModel>> fetchCart(String? userId) async {
    final client = _client;
    if (client != null && userId != null && userId.isNotEmpty) {
      try {
        final response = await client
            .from('cart_items')
            .select('*, products(*, categories(name), seller_profiles(store_name))')
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        final list = response as List<dynamic>;
        _localItems.clear();
        for (final item in list) {
          _localItems.add(CartItemModel.fromJson(item));
        }
        _updateNotifier();
        return items;
      } catch (e) {
        debugPrint('Notice fetchCart Supabase: $e');
      }
    }

    _updateNotifier();
    return items;
  }

  /// Menambah produk ke keranjang.
  Future<void> addToCart(String? userId, ProductModel product, {int quantity = 1}) async {
    final existingIndex =
        _localItems.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      final current = _localItems[existingIndex];
      final newQuantity = (current.quantity + quantity).clamp(1, product.stock);
      _localItems[existingIndex] = current.copyWith(
        quantity: newQuantity,
        product: product,
      );
    } else {
      final initialQuantity = quantity.clamp(1, product.stock > 0 ? product.stock : 1);
      _localItems.add(CartItemModel(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}_${product.id}',
        userId: userId ?? '',
        productId: product.id,
        quantity: initialQuantity,
        product: product,
      ));
    }

    _updateNotifier();

    final client = _client;
    if (client != null && userId != null && userId.isNotEmpty) {
      try {
        final item = _localItems.firstWhere((it) => it.productId == product.id);
        await client.from('cart_items').upsert({
          'user_id': userId,
          'product_id': product.id,
          'quantity': item.quantity,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Notice addToCart Supabase: $e');
      }
    }
  }

  /// Memperbarui kuantitas produk tertentu.
  Future<void> updateQuantity(String? userId, String productId, int quantity) async {
    final index = _localItems.indexWhere((item) => item.productId == productId);
    if (index < 0) return;

    if (quantity <= 0) {
      await removeFromCart(userId, productId);
      return;
    }

    final current = _localItems[index];
    final validQuantity = quantity.clamp(1, current.product.stock);
    _localItems[index] = current.copyWith(quantity: validQuantity);
    _updateNotifier();

    final client = _client;
    if (client != null && userId != null && userId.isNotEmpty) {
      try {
        await client
            .from('cart_items')
            .update({
              'quantity': validQuantity,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', userId)
            .eq('product_id', productId);
      } catch (e) {
        debugPrint('Notice updateQuantity Supabase: $e');
      }
    }
  }

  /// Menghapus produk dari keranjang.
  Future<void> removeFromCart(String? userId, String productId) async {
    _localItems.removeWhere((item) => item.productId == productId);
    _updateNotifier();

    final client = _client;
    if (client != null && userId != null && userId.isNotEmpty) {
      try {
        await client
            .from('cart_items')
            .delete()
            .eq('user_id', userId)
            .eq('product_id', productId);
      } catch (e) {
        debugPrint('Notice removeFromCart Supabase: $e');
      }
    }
  }

  /// Mengosongkan keranjang (misalnya setelah checkout sukses).
  Future<void> clearCart(String? userId) async {
    _localItems.clear();
    _updateNotifier();

    final client = _client;
    if (client != null && userId != null && userId.isNotEmpty) {
      try {
        await client.from('cart_items').delete().eq('user_id', userId);
      } catch (e) {
        debugPrint('Notice clearCart Supabase: $e');
      }
    }
  }
}

