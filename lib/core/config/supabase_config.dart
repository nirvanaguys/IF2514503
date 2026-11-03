class SupabaseConfig {
  SupabaseConfig._();

  /// Default Supabase Project URL.
  /// Mendukung override melalui `--dart-define=SUPABASE_URL=...`
  static const String defaultUrl = 'https://gqdwwgbtadvujqfidobf.supabase.co';

  /// Default Supabase Publishable Key.
  /// Mendukung override melalui `--dart-define=SUPABASE_PUBLISHABLE_KEY=...` atau `--dart-define=SUPABASE_ANON_KEY=...`
  static const String defaultPublishableKey =
      'sb_publishable_UlXcwDH27IkEJ0cv4qqkLw_Odigwc2a';

  /// URL aktif aplikasi (dipastikan tanpa akhiran `/rest/v1/`).
  static String get url {
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    final raw = fromEnv.isNotEmpty ? fromEnv : defaultUrl;
    return cleanUrl(raw);
  }

  /// Publishable key aktif aplikasi.
  static String get publishableKey {
    const fromEnvPubKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (fromEnvPubKey.isNotEmpty) return fromEnvPubKey;

    const fromEnvAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnvAnonKey.isNotEmpty) return fromEnvAnonKey;

    return defaultPublishableKey;
  }

  /// Memastikan URL tidak mengandung path `/rest/v1/` yang dapat merusak
  /// endpoint auth (`/auth/v1`) maupun query REST Supabase.
  static String cleanUrl(String rawUrl) {
    var trimmed = rawUrl.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('/rest/v1')) {
      trimmed = trimmed.substring(0, trimmed.length - '/rest/v1'.length);
    }
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
