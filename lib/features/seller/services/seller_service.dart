import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/errors/app_exception.dart';
import '../../marketplace/models/product_model.dart';
import '../models/seller_profile_model.dart';

class SellerService {
  final supa.SupabaseClient? _client;
  static SellerProfileModel? _cachedSellerProfile;
  static final List<ProductModel> _cachedSellerProducts = [];

  SellerService({supa.SupabaseClient? client})
      : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil profil toko penjual untuk pengguna aktif.
  Future<SellerProfileModel?> fetchSellerProfile(String userId) async {
    final client = _client;
    if (client != null && userId.isNotEmpty) {
      try {
        final response = await client
            .from('seller_profiles')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        if (response != null) {
          final profile = SellerProfileModel.fromJson(response);
          _cachedSellerProfile = profile;
          return profile;
        }
      } catch (e) {
        debugPrint('Notice fetchSellerProfile Supabase: $e');
      }
    }

    return _cachedSellerProfile;
  }

  /// Mendaftarkan profil toko baru.
  Future<SellerProfileModel> registerSeller({
    required String userId,
    required String storeName,
    String? description,
  }) async {
    final cleanName = storeName.trim();
    if (cleanName.isEmpty) {
      throw const ValidationException('Nama toko tidak boleh kosong.');
    }

    final newProfile = SellerProfileModel(
      id: 'seller_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      storeName: cleanName,
      description: description?.trim(),
      status: 'active',
      createdAt: DateTime.now(),
    );

    final client = _client;
    if (client != null && userId.isNotEmpty) {
      try {
        final payload = {
          'user_id': userId,
          'store_name': cleanName,
          'description': description?.trim(),
          'status': 'active',
        };

        final response = await client
            .from('seller_profiles')
            .upsert(payload, onConflict: 'user_id')
            .select()
            .single();

        final saved = SellerProfileModel.fromJson(response);
        _cachedSellerProfile = saved;
        return saved;
      } catch (e) {
        debugPrint('Notice registerSeller Supabase: $e');
      }
    }

    _cachedSellerProfile = newProfile;
    return newProfile;
  }

  /// Mengambil seluruh produk yang dimiliki oleh toko penjual ini.
  Future<List<ProductModel>> fetchSellerProducts(String userId) async {
    final client = _client;
    if (client != null && userId.isNotEmpty) {
      try {
        final response = await client
            .from('products')
            .select('*, categories(name)')
            .eq('seller_id', userId)
            .order('created_at', ascending: false);

        final list = (response as List<dynamic>)
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();

        _cachedSellerProducts
          ..clear()
          ..addAll(list);

        return list;
      } catch (e) {
        debugPrint('Notice fetchSellerProducts Supabase: $e');
      }
    }

    return List.unmodifiable(_cachedSellerProducts);
  }

  /// Menambah produk baru ke toko penjual.
  Future<ProductModel> createProduct({
    required String sellerId,
    required String name,
    required String description,
    required String category,
    required int price,
    required int stock,
    required String imageUrl,
    String storeName = 'Toko Saya',
  }) async {
    if (name.trim().isEmpty) {
      throw const ValidationException('Nama produk wajib diisi.');
    }
    if (price < 0) {
      throw const ValidationException('Harga produk tidak boleh negatif.');
    }
    if (stock < 0) {
      throw const ValidationException('Stok produk tidak boleh negatif.');
    }

    final newProduct = ProductModel(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
      storeName: storeName,
      category: category,
      sellerId: sellerId,
      price: price,
      stock: stock,
      rating: 5.0,
      reviewCount: 0,
      imageUrl: imageUrl.trim(),
      images: imageUrl.trim().isNotEmpty ? [imageUrl.trim()] : [],
      isPublished: true,
    );

    final client = _client;
    if (client != null && sellerId.isNotEmpty) {
      try {
        final payload = {
          'seller_id': sellerId,
          'name': name.trim(),
          'description': description.trim(),
          'price': price,
          'stock': stock,
          'image_paths': imageUrl.trim().isNotEmpty ? [imageUrl.trim()] : [],
          'is_published': true,
        };

        final response = await client.from('products').insert(payload).select().single();
        final saved = ProductModel.fromJson(response);
        _cachedSellerProducts.insert(0, saved);
        return saved;
      } catch (e) {
        debugPrint('Notice createProduct Supabase: $e');
      }
    }

    _cachedSellerProducts.insert(0, newProduct);
    return newProduct;
  }

  /// Memperbarui produk yang sudah ada.
  Future<ProductModel> updateProduct(ProductModel product) async {
    final client = _client;
    final index = _cachedSellerProducts.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _cachedSellerProducts[index] = product;
    }

    if (client != null && product.sellerId != null) {
      try {
        final payload = {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'stock': product.stock,
          'image_paths': product.images.isNotEmpty ? product.images : [product.imageUrl],
          'is_published': product.isPublished,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await client
            .from('products')
            .update(payload)
            .eq('id', product.id)
            .eq('seller_id', product.sellerId!);
      } catch (e) {
        debugPrint('Notice updateProduct Supabase: $e');
      }
    }

    return product;
  }

  /// Menghapus produk dari toko.
  Future<void> deleteProduct(String productId, String sellerId) async {
    _cachedSellerProducts.removeWhere((p) => p.id == productId);

    final client = _client;
    if (client != null && sellerId.isNotEmpty) {
      try {
        await client
            .from('products')
            .delete()
            .eq('id', productId)
            .eq('seller_id', sellerId);
      } catch (e) {
        debugPrint('Notice deleteProduct Supabase: $e');
      }
    }
  }

  /// Upload gambar produk ke Supabase Storage bucket 'products'.
  Future<String?> uploadImageBytes(
    String sellerId,
    Uint8List bytes,
    String fileName,
  ) async {
    final client = _client;
    if (client == null) return null;

    try {
      final sanitizedName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path = '$sellerId/${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';

      await client.storage.from('products').uploadBinary(
            path,
            bytes,
            fileOptions: const supa.FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = client.storage.from('products').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Notice uploadImageBytes Supabase Storage: $e');
      return null;
    }
  }
}

