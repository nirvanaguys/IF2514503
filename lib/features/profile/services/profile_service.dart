import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/errors/app_exception.dart';
import '../../auth/models/user_profile.dart';

class ProfileService {
  final supa.SupabaseClient? _client;

  ProfileService({supa.SupabaseClient? client})
      : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil data profil berdasarkan userId.
  Future<UserProfile> getProfile(String userId, {String email = ''}) async {
    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(data, fallbackEmail: email);
    } catch (e) {
      debugPrint('Error getProfile: $e');
      throw const DatabaseException('Gagal memuat profil pengguna.');
    }
  }

  /// Memperbarui nama tampilan dan nomor telepon profil.
  Future<UserProfile> updateProfile({
    required String userId,
    required String displayName,
    String? phone,
    String? avatarPath,
    String email = '',
  }) async {
    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    final cleanName = displayName.trim();
    if (cleanName.isEmpty) {
      throw const ValidationException('Nama tampilan tidak boleh kosong.');
    }

    try {
      final updateData = <String, dynamic>{
        'display_name': cleanName,
        'phone': phone?.trim(),
        'updated_at': DateTime.now().toIso8601String(),
        ...?avatarPath != null ? {'avatar_path': avatarPath} : null,
      };

      await client.from('profiles').update(updateData).eq('id', userId);

      return UserProfile(
        id: userId,
        displayName: cleanName,
        email: email,
        phone: phone?.trim(),
        avatarPath: avatarPath,
      );
    } catch (e) {
      debugPrint('Error updateProfile: $e');
      throw const DatabaseException('Gagal memperbarui profil. Silakan coba lagi.');
    }
  }
}
