import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/errors/app_exception.dart';
import '../models/user_profile.dart';

class AuthService {
  final supa.SupabaseClient? _client;

  AuthService({supa.SupabaseClient? client})
      : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  supa.User? get currentUser => _client?.auth.currentUser;
  supa.Session? get currentSession => _client?.auth.currentSession;
  bool get isAuthenticated => currentUser != null;

  Stream<supa.AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  /// Registrasi akun baru dengan email, kata sandi, dan nama tampilan.
  Future<supa.AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw const ValidationException('Format email tidak valid.');
    }
    if (password.length < 6) {
      throw const ValidationException('Kata sandi minimal 6 karakter.');
    }
    if (displayName.trim().isEmpty) {
      throw const ValidationException('Nama tampilan tidak boleh kosong.');
    }

    try {
      final response = await client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'display_name': displayName.trim()},
      );

      // Simpan/sinkronkan profil awal secara eksplisit bila user langsung aktif
      if (response.user != null) {
        try {
          await client.from('profiles').upsert({
            'id': response.user!.id,
            'display_name': displayName.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('Profile trigger fallback notice: $e');
        }
      }

      return response;
    } on supa.AuthException catch (e) {
      throw AuthException(_mapAuthErrorMessage(e.message), code: e.statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Gagal mendaftar: ${e.toString()}');
    }
  }

  /// Masuk dengan email dan kata sandi.
  Future<supa.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw const ValidationException('Format email tidak valid.');
    }
    if (password.isEmpty) {
      throw const ValidationException('Kata sandi wajib diisi.');
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );
      return response;
    } on supa.AuthException catch (e) {
      throw AuthException(_mapAuthErrorMessage(e.message), code: e.statusCode);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AuthException('Gagal masuk: ${e.toString()}');
    }
  }

  /// Keluar dari sesi akun saat ini.
  Future<void> signOut() async {
    try {
      await _client?.auth.signOut();
    } catch (e) {
      debugPrint('SignOut notice: $e');
    }
  }

  /// Mengambil profil pengguna yang sedang login dari tabel `profiles`.
  Future<UserProfile?> fetchCurrentProfile() async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return null;

    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromJson(data, fallbackEmail: user.email ?? '');
      }

      final fallbackName = user.userMetadata?['display_name'] as String? ??
          (user.email?.split('@').first ?? 'Pengguna DaunKu');

      return UserProfile(
        id: user.id,
        displayName: fallbackName,
        email: user.email ?? '',
      );
    } catch (e) {
      debugPrint('Gagal fetch profile: $e');
      return UserProfile(
        id: user.id,
        displayName: user.email?.split('@').first ?? 'Pengguna DaunKu',
        email: user.email ?? '',
      );
    }
  }

  String _mapAuthErrorMessage(String rawMessage) {
    final lower = rawMessage.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Email atau kata sandi salah. Silakan coba lagi.';
    }
    if (lower.contains('user already registered')) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }
    if (lower.contains('password should be at least')) {
      return 'Kata sandi minimal 6 karakter.';
    }
    if (lower.contains('network') || lower.contains('connection')) {
      return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
    }
    return rawMessage;
  }
}
