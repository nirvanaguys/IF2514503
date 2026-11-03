import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daunku_app/features/seller/models/seller_profile_model.dart';
import 'package:daunku_app/features/seller/screens/add_edit_product_screen.dart';
import 'package:daunku_app/features/seller/screens/register_seller_screen.dart';
import 'package:daunku_app/features/seller/screens/seller_dashboard_screen.dart';
import 'package:daunku_app/features/seller/services/seller_service.dart';

void main() {
  group('SellerProfileModel tests', () {
    test('fromJson and toJson parse attributes accurately', () {
      final json = {
        'id': 'seller-1',
        'user_id': 'user-1',
        'store_name': 'Kebun Berkah',
        'description': 'Toko pupuk organik',
        'status': 'active',
      };

      final profile = SellerProfileModel.fromJson(json);

      expect(profile.id, 'seller-1');
      expect(profile.storeName, 'Kebun Berkah');
      expect(profile.isActive, isTrue);

      final serialized = profile.toJson();
      expect(serialized['store_name'], 'Kebun Berkah');
      expect(serialized['status'], 'active');
    });
  });

  group('SellerService tests', () {
    final sellerService = SellerService();

    test('registerSeller creates profile and caches it', () async {
      final profile = await sellerService.registerSeller(
        userId: 'user-test-123',
        storeName: 'Agro Jaya',
        description: 'Toko pertanian terpercaya',
      );

      expect(profile.storeName, 'Agro Jaya');
      expect(profile.userId, 'user-test-123');
      expect(profile.isActive, isTrue);
    });

    test('createProduct adds product for seller', () async {
      final product = await sellerService.createProduct(
        sellerId: 'user-test-123',
        name: 'Bibit Tomat Unggul',
        description: 'Benih berkualitas',
        category: 'Media Tanam',
        price: 15000,
        stock: 50,
        imageUrl: '',
      );

      expect(product.name, 'Bibit Tomat Unggul');
      expect(product.price, 15000);
      expect(product.stock, 50);

      final sellerProducts = await sellerService.fetchSellerProducts('user-test-123');
      expect(sellerProducts.any((p) => p.name == 'Bibit Tomat Unggul'), isTrue);
    });
  });

  group('Seller UI screen widget tests', () {
    testWidgets('RegisterSellerScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RegisterSellerScreen()),
      );
      expect(find.text('Daftar Sebagai Penjual'), findsOneWidget);
      expect(find.text('Nama Toko Pertanian'), findsOneWidget);
      expect(find.text('Aktifkan Toko Sekarang'), findsOneWidget);
    });

    testWidgets('SellerDashboardScreen renders store info and action', (tester) async {
      const profile = SellerProfileModel(
        id: 's-1',
        userId: 'u-1',
        storeName: 'Toko Bunga Melati',
      );

      await tester.pumpWidget(
        const MaterialApp(home: SellerDashboardScreen(sellerProfile: profile)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pusat Penjual'), findsOneWidget);
      expect(find.text('Toko Bunga Melati'), findsOneWidget);
      expect(find.text('Total Produk'), findsOneWidget);
    });

    testWidgets('AddEditProductScreen renders form inputs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddEditProductScreen(sellerId: 'u-1', storeName: 'Toko Melati'),
        ),
      );

      expect(find.text('Tambah Produk Baru'), findsOneWidget);
      expect(find.text('Nama Produk'), findsOneWidget);
      expect(find.text('Harga (Rupiah)'), findsOneWidget);
      expect(find.text('Terbitkan Produk'), findsOneWidget);
    });
  });
}

