import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../models/address_model.dart';

class AddressService {
  final supa.SupabaseClient? _client;
  static final List<AddressModel> _localAddresses = [];

  AddressService({supa.SupabaseClient? client})
      : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil daftar alamat pengiriman pengguna.
  Future<List<AddressModel>> fetchAddresses(String userId) async {
    final client = _client;
    if (client != null && userId.isNotEmpty) {
      try {
        final response = await client
            .from('addresses')
            .select()
            .eq('user_id', userId)
            .order('is_default', ascending: false)
            .order('created_at', ascending: false);

        final list = (response as List<dynamic>)
            .map((item) => AddressModel.fromJson(item))
            .toList();

        _localAddresses
          ..clear()
          ..addAll(list);

        return list;
      } catch (e) {
        debugPrint('Notice fetchAddresses Supabase: $e');
      }
    }

    // Fallback alamat lokal contoh jika belum ada alamat
    if (_localAddresses.isEmpty) {
      _localAddresses.add(
        AddressModel(
          id: 'addr_default_1',
          userId: userId,
          recipientName: 'Wisnu Wardhana',
          phone: '081234567890',
          addressLine: 'Jl. Melati Hijau No. 12, RT 03/RW 04',
          city: 'Jakarta Selatan',
          province: 'DKI Jakarta',
          postalCode: '12410',
          isDefault: true,
        ),
      );
    }

    return List.unmodifiable(_localAddresses);
  }

  /// Menambah atau mengedit alamat pengiriman.
  Future<AddressModel> saveAddress(AddressModel address) async {
    final client = _client;

    // Jika dijadikan default, reset alamat lainnya
    if (address.isDefault) {
      for (int i = 0; i < _localAddresses.length; i++) {
        _localAddresses[i] = _localAddresses[i].copyWith(isDefault: false);
      }
    }

    final existingIndex = _localAddresses.indexWhere((a) => a.id == address.id);
    if (existingIndex >= 0) {
      _localAddresses[existingIndex] = address;
    } else {
      _localAddresses.add(address);
    }

    if (client != null && address.userId.isNotEmpty) {
      try {
        if (address.isDefault) {
          await client
              .from('addresses')
              .update({'is_default': false})
              .eq('user_id', address.userId);
        }

        final data = address.toJson();
        if (address.id.startsWith('addr_') && address.id.length < 30) {
          data.remove('id'); // Biarkan Supabase meng-generate UUID
        }

        final response = await client.from('addresses').upsert(data).select().single();
        return AddressModel.fromJson(response);
      } catch (e) {
        debugPrint('Notice saveAddress Supabase: $e');
      }
    }

    return address;
  }

  /// Menghapus alamat pengiriman.
  Future<void> deleteAddress(String userId, String addressId) async {
    _localAddresses.removeWhere((a) => a.id == addressId);

    final client = _client;
    if (client != null && userId.isNotEmpty) {
      try {
        await client
            .from('addresses')
            .delete()
            .eq('user_id', userId)
            .eq('id', addressId);
      } catch (e) {
        debugPrint('Notice deleteAddress Supabase: $e');
      }
    }
  }
}

