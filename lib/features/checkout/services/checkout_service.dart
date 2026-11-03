import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/errors/app_exception.dart';
import '../../cart/models/cart_item_model.dart';
import '../../cart/services/cart_service.dart';
import '../../marketplace/models/product_model.dart';
import '../../orders/models/order_model.dart';
import '../../orders/services/order_service.dart';
import '../models/address_model.dart';

class CheckoutService {
  final supa.SupabaseClient? _client;
  final OrderService _orderService = OrderService();
  final CartService _cartService = CartService();

  /// Menyimpan idempotency key terakhir yang berhasil diproses
  /// untuk mencegah pembuatan pesanan duplikat.
  static String? _lastProcessedIdempotencyKey;

  CheckoutService({supa.SupabaseClient? client})
    : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Membuat pesanan baru dengan validasi stok/harga dari server
  /// dan pengurangan stok atomik.
  Future<OrderModel> createOrder({
    required String userId,
    required AddressModel address,
    required List<CartItemModel> items,
    int shippingCost = 15000,
    String paymentProvider = 'Transfer Bank (BCA Virtual Account)',
    String? idempotencyKey,
  }) async {
    if (items.isEmpty) {
      throw const ValidationException('Keranjang belanja kosong.');
    }
    if (address.addressLine.isEmpty || address.recipientName.isEmpty) {
      throw const ValidationException('Alamat pengiriman belum lengkap.');
    }

    // Cek idempotency: jangan proses key yang sama dua kali
    final effectiveKey =
        idempotencyKey ?? '${userId}_${DateTime.now().millisecondsSinceEpoch}';
    if (_lastProcessedIdempotencyKey == effectiveKey) {
      throw const ValidationException(
        'Pesanan ini sudah diproses. Silakan periksa halaman pesanan Anda.',
      );
    }

    for (final item in items) {
      if (item.quantity <= 0) {
        throw const ValidationException('Kuantitas produk tidak valid.');
      }
    }

    final client = _client;
    if (client != null && userId.isNotEmpty) {
      return _createOrderWithServerValidation(
        client: client,
        userId: userId,
        address: address,
        items: items,
        shippingCost: shippingCost,
        paymentProvider: paymentProvider,
        effectiveKey: effectiveKey,
      );
    }

    // Fallback mode offline / demo
    return _createOrderOffline(
      userId: userId,
      address: address,
      items: items,
      shippingCost: shippingCost,
      paymentProvider: paymentProvider,
      effectiveKey: effectiveKey,
    );
  }

  /// Membuat pesanan dengan validasi harga/stok dari database server.
  Future<OrderModel> _createOrderWithServerValidation({
    required supa.SupabaseClient client,
    required String userId,
    required AddressModel address,
    required List<CartItemModel> items,
    required int shippingCost,
    required String paymentProvider,
    required String effectiveKey,
  }) async {
    // 1. Ambil data produk terbaru dari database untuk validasi harga & stok
    final productIds = items.map((it) => it.productId).toList();
    final List<ProductModel> serverProducts;

    try {
      final response = await client
          .from('products')
          .select('*, categories(name), seller_profiles(store_name)')
          .inFilter('id', productIds)
          .eq('is_published', true);

      final list = response as List<dynamic>;
      serverProducts = list.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Notice fetchProducts for checkout: $e');
      throw const DatabaseException(
        'Gagal memverifikasi data produk. Silakan coba lagi.',
      );
    }

    // 2. Validasi setiap item: produk harus ada, aktif, stok cukup
    //    Harga diambil dari server, bukan dari client
    int subtotal = 0;
    final validatedItems = <_ValidatedItem>[];

    for (final cartItem in items) {
      final matches = serverProducts
          .where((p) => p.id == cartItem.productId)
          .toList();

      if (matches.isEmpty) {
        throw ValidationException(
          'Produk "${cartItem.product.name}" tidak tersedia atau sudah dihapus.',
        );
      }

      final product = matches.first;

      if (product.stock <= 0) {
        throw ValidationException('Stok "${product.name}" sudah habis.');
      }

      if (cartItem.quantity > product.stock) {
        throw ValidationException(
          'Stok "${product.name}" tidak mencukupi. '
          'Tersedia: ${product.stock}, diminta: ${cartItem.quantity}.',
        );
      }

      // Gunakan harga dari server, bukan dari client
      final lineTotal = product.price * cartItem.quantity;
      subtotal += lineTotal;

      validatedItems.add(
        _ValidatedItem(
          cartItem: cartItem,
          serverProduct: product,
          lineTotal: lineTotal,
        ),
      );
    }

    final int total = subtotal + shippingCost;
    final paymentReference =
        'VA-8829-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    try {
      // 3. Buat order di database
      final orderData = {
        'buyer_id': userId,
        'status': 'pending_payment',
        'subtotal': subtotal,
        'shipping_cost': shippingCost,
        'total': total,
        'shipping_address_snapshot': address.toJson(),
        'payment_provider': paymentProvider,
        'payment_reference': paymentReference,
      };

      final response = await client
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      final realOrderId = response['id'] as String;

      // 4. Simpan snapshot item pesanan (gunakan harga server)
      final itemsPayload = validatedItems.map((vi) {
        return {
          'order_id': realOrderId,
          'product_id': vi.cartItem.productId,
          'seller_id': vi.serverProduct.sellerId ?? userId,
          'product_name_snapshot': vi.serverProduct.name,
          'unit_price': vi.serverProduct.price,
          'quantity': vi.cartItem.quantity,
          'line_total': vi.lineTotal,
        };
      }).toList();

      await client.from('order_items').insert(itemsPayload);

      // 5. Kurangi stok produk
      for (final vi in validatedItems) {
        try {
          // Coba gunakan RPC function untuk pengurangan stok atomik
          await client.rpc(
            'decrement_stock',
            params: {
              'p_product_id': vi.cartItem.productId,
              'p_quantity': vi.cartItem.quantity,
            },
          );
        } catch (rpcError) {
          // Fallback: kurangi stok dengan update langsung
          debugPrint(
            'Notice RPC decrement_stock not available, using direct update: $rpcError',
          );
          try {
            final currentProduct = await client
                .from('products')
                .select('stock')
                .eq('id', vi.cartItem.productId)
                .single();
            final currentStock = currentProduct['stock'] as int;
            final newStock = (currentStock - vi.cartItem.quantity).clamp(
              0,
              currentStock,
            );
            await client
                .from('products')
                .update({'stock': newStock})
                .eq('id', vi.cartItem.productId);
          } catch (updateError) {
            debugPrint('Notice update stock fallback: $updateError');
          }
        }
      }

      // 6. Kosongkan keranjang
      await _cartService.clearCart(userId);

      // 7. Tandai idempotency key sebagai telah diproses
      _lastProcessedIdempotencyKey = effectiveKey;

      final orderItemModels = validatedItems.map((vi) {
        return OrderItemModel(
          id: 'item_${realOrderId}_${vi.cartItem.productId}',
          orderId: realOrderId,
          productId: vi.cartItem.productId,
          sellerId: vi.serverProduct.sellerId ?? userId,
          productName: vi.serverProduct.name,
          unitPrice: vi.serverProduct.price,
          quantity: vi.cartItem.quantity,
          lineTotal: vi.lineTotal,
          imageUrl: vi.serverProduct.imageUrl,
        );
      }).toList();

      final createdOrder = OrderModel(
        id: realOrderId,
        buyerId: userId,
        status: 'pending_payment',
        subtotal: subtotal,
        shippingCost: shippingCost,
        total: total,
        shippingAddressSnapshot: address.toJson(),
        paymentProvider: paymentProvider,
        paymentReference: paymentReference,
        createdAt: DateTime.now(),
        items: orderItemModels,
      );

      _orderService.addLocalOrder(createdOrder);
      return createdOrder;
    } catch (e) {
      if (e is AppException) rethrow;
      debugPrint('Notice createOrder Supabase: $e');
      throw const DatabaseException(
        'Gagal membuat pesanan. Silakan coba lagi.',
      );
    }
  }

  /// Fallback: membuat pesanan secara offline tanpa validasi server.
  Future<OrderModel> _createOrderOffline({
    required String userId,
    required AddressModel address,
    required List<CartItemModel> items,
    required int shippingCost,
    required String paymentProvider,
    required String effectiveKey,
  }) async {
    int subtotal = 0;
    for (final item in items) {
      subtotal += item.product.price * item.quantity;
    }
    final int total = subtotal + shippingCost;
    final String orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}';

    final orderItems = items.map((it) {
      return OrderItemModel(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}_${it.productId}',
        orderId: orderId,
        productId: it.productId,
        sellerId: it.product.sellerId ?? userId,
        productName: it.product.name,
        unitPrice: it.product.price,
        quantity: it.quantity,
        lineTotal: it.product.price * it.quantity,
        imageUrl: it.product.imageUrl,
      );
    }).toList();

    final order = OrderModel(
      id: orderId,
      buyerId: userId,
      status: 'pending_payment',
      subtotal: subtotal,
      shippingCost: shippingCost,
      total: total,
      shippingAddressSnapshot: address.toJson(),
      paymentProvider: paymentProvider,
      paymentReference:
          'VA-8829-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      createdAt: DateTime.now(),
      items: orderItems,
    );

    _lastProcessedIdempotencyKey = effectiveKey;
    _orderService.addLocalOrder(order);
    await _cartService.clearCart(userId);
    return order;
  }
}

/// Helper class untuk menyimpan item tervalidasi beserta data server.
class _ValidatedItem {
  final CartItemModel cartItem;
  final ProductModel serverProduct;
  final int lineTotal;

  const _ValidatedItem({
    required this.cartItem,
    required this.serverProduct,
    required this.lineTotal,
  });
}
