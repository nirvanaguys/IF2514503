import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daunku_app/features/auth/models/user_profile.dart';
import 'package:daunku_app/features/auth/screens/login_screen.dart';
import 'package:daunku_app/features/auth/screens/register_screen.dart';
import 'package:daunku_app/features/profile/screens/edit_profile_screen.dart';

void main() {
  group('UserProfile model tests', () {
    test('fromJson and toJson work correctly', () {
      final json = {
        'id': 'user-uuid-123',
        'display_name': 'Budi Santoso',
        'phone': '08123456789',
        'created_at': '2026-01-01T00:00:00.000Z',
      };

      final profile = UserProfile.fromJson(json, fallbackEmail: 'budi@daunku.com');

      expect(profile.id, 'user-uuid-123');
      expect(profile.displayName, 'Budi Santoso');
      expect(profile.email, 'budi@daunku.com');
      expect(profile.phone, '08123456789');

      final serialized = profile.toJson();
      expect(serialized['id'], 'user-uuid-123');
      expect(serialized['display_name'], 'Budi Santoso');
      expect(serialized['phone'], '08123456789');
    });

    test('copyWith updates fields as expected', () {
      const initial = UserProfile(
        id: '1',
        displayName: 'Awal',
        email: 'awal@email.com',
      );

      final updated = initial.copyWith(displayName: 'Baru');
      expect(updated.displayName, 'Baru');
      expect(updated.email, 'awal@email.com');
      expect(updated.id, '1');
    });
  });

  group('Auth & Profile UI screens render test', () {
    testWidgets('LoginScreen renders required inputs and buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.text('Selamat Datang Kembali'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.text('Daftar Sekarang'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders registration form', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RegisterScreen(),
        ),
      );

      expect(find.text('Buat Akun Baru'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Konfirmasi Kata Sandi'), findsOneWidget);
      expect(find.text('Daftar Sekarang'), findsOneWidget);
    });

    testWidgets('EditProfileScreen renders initial user data', (tester) async {
      const profile = UserProfile(
        id: '123',
        displayName: 'Wisnu Wardhana',
        email: 'wisnu@email.com',
        phone: '08111222333',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(initialProfile: profile),
        ),
      );

      expect(find.text('Edit Profil'), findsOneWidget);
      expect(find.text('Wisnu Wardhana'), findsWidgets);
      expect(find.text('wisnu@email.com'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
    });
  });
}

