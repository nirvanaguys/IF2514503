import 'package:flutter_test/flutter_test.dart';
import 'package:daunku_app/core/config/supabase_config.dart';

void main() {
  group('SupabaseConfig tests', () {
    test('cleanUrl strips trailing slashes and /rest/v1', () {
      expect(
        SupabaseConfig.cleanUrl('https://example.supabase.co/rest/v1/'),
        'https://example.supabase.co',
      );
      expect(
        SupabaseConfig.cleanUrl('https://example.supabase.co/rest/v1'),
        'https://example.supabase.co',
      );
      expect(
        SupabaseConfig.cleanUrl('https://example.supabase.co/'),
        'https://example.supabase.co',
      );
      expect(
        SupabaseConfig.cleanUrl('https://example.supabase.co'),
        'https://example.supabase.co',
      );
    });

    test('default configuration values are valid', () {
      expect(SupabaseConfig.url, isNotEmpty);
      expect(SupabaseConfig.url.endsWith('/rest/v1'), isFalse);
      expect(SupabaseConfig.publishableKey, isNotEmpty);
    });
  });
}

