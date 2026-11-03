import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../data/marketplace_demo_data.dart';

class MarketplaceService {
  final supa.SupabaseClient? _client;

  MarketplaceService({supa.SupabaseClient? client})
      : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil daftar kategori produk dari Supabase (dengan fallback kategori standar).
  Future<List<String>> fetchCategories() async {
    final client = _client;
    if (client == null) {
      return MarketplaceDemoData.categories;
    }

    try {
      final response = await client
          .from('categories')
          .select('name')
          .eq('is_active', true)
          .order('name');

      final list = (response as List<dynamic>)
          .map((item) => item['name'] as String)
          .toList();

      if (list.isNotEmpty) {
        if (!list.contains('Semua')) {
          list.insert(0, 'Semua');
        }
        return list;
      }
    } catch (e) {
      debugPrint('Notice fetchCategories Supabase: $e');
    }

    return MarketplaceDemoData.categories;
  }

  /// Mengambil katalog produk dengan filter kategori, pencarian, dan pengurutan.
  Future<List<ProductModel>> fetchProducts({
    String selectedCategory = 'Semua',
    String searchQuery = '',
    String sortBy = 'Terpopuler',
  }) async {
    final client = _client;

    List<ProductModel> results = [];

    if (client != null) {
      try {
        var queryBuilder = client
            .from('products')
            .select('*, categories(name), seller_profiles(store_name)')
            .eq('is_published', true);

        if (selectedCategory != 'Semua') {
          queryBuilder = queryBuilder.eq('categories.name', selectedCategory);
        }

        final response = await queryBuilder;
        final list = response as List<dynamic>;

        if (list.isNotEmpty) {
          results = list.map((json) => ProductModel.fromJson(json)).toList();
        }
      } catch (e) {
        debugPrint('Notice fetchProducts Supabase: $e');
      }
    }

    // Jika database masih kosong atau offline, gunakan data fallback standar
    if (results.isEmpty) {
      results = List.of(MarketplaceDemoData.products);
    }

    // Filter Kategori (Client-side / Fallback guarantee)
    if (selectedCategory != 'Semua') {
      results = results
          .where((p) => p.category.toLowerCase() == selectedCategory.toLowerCase())
          .toList();
    }

    // Filter Pencarian
    final cleanQuery = searchQuery.trim().toLowerCase();
    if (cleanQuery.isNotEmpty) {
      results = results.where((p) {
        return p.name.toLowerCase().contains(cleanQuery) ||
            p.storeName.toLowerCase().contains(cleanQuery) ||
            p.category.toLowerCase().contains(cleanQuery);
      }).toList();
    }

    // Pengurutan (Sorting)
    switch (sortBy) {
      case 'Harga Termurah':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Harga Tertinggi':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Terpopuler':
      default:
        results.sort((a, b) {
          final cmpRating = b.rating.compareTo(a.rating);
          if (cmpRating != 0) return cmpRating;
          return b.reviewCount.compareTo(a.reviewCount);
        });
        break;
    }

    return results;
  }

  /// Mengambil detail satu produk berdasarkan ID.
  Future<ProductModel?> fetchProductById(String id) async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client
            .from('products')
            .select('*, categories(name), seller_profiles(store_name)')
            .eq('id', id)
            .maybeSingle();

        if (response != null) {
          return ProductModel.fromJson(response);
        }
      } catch (e) {
        debugPrint('Notice fetchProductById Supabase: $e');
      }
    }

    // Fallback
    try {
      return MarketplaceDemoData.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
