import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daunku_app/app.dart';

void main() {
  testWidgets('App renders Beranda and Marketplace correctly according to design',
      (WidgetTester tester) async {
    // Set realistic mobile phone viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const DaunKuApp());

    // 1. Verify Beranda elements
    expect(find.text('Halo, Wisnu 👋'), findsOneWidget);
    expect(find.text('Diagnosis Sekarang'), findsOneWidget);

    // 2. Tap "Diagnosis Sekarang" button on Beranda hero card
    await tester.tap(find.text('Diagnosis Sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Ambil Foto Langsung'), findsOneWidget);

    // 3. Switch to Marketplace
    await tester.tap(find.text('Marketplace'));
    await tester.pumpAndSettle();

    // Verify Marketplace elements
    expect(find.text('Marketplace Pertanian'), findsOneWidget);
    expect(find.text('Pupuk Organik'), findsOneWidget);
    expect(find.text('Fungisida Organik Neem Oil 250ml'), findsWidgets);

    // 4. Test filter category "Pupuk Organik"
    await tester.tap(find.text('Pupuk Organik'));
    await tester.pumpAndSettle();
    expect(find.text('Pupuk Daun NPK Spray 500ml'), findsOneWidget);

    // 5. Test adding to cart
    await tester.tap(find.text('+ Keranjang').first);
    await tester.pump();
    expect(find.textContaining('ditambahkan ke keranjang'), findsOneWidget);

    // 6. Switch to Profil
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Wisnu Wardhana'), findsOneWidget);
    expect(find.text('Diagnosis Selesai'), findsOneWidget);
    expect(find.text('Keluar dari Akun'), findsOneWidget);
  });
}
