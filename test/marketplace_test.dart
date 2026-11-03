import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daunku_app/features/marketplace/models/product_model.dart';
import 'package:daunku_app/features/marketplace/screens/product_detail_screen.dart';
import 'package:daunku_app/features/marketplace/services/marketplace_service.dart';

void main() {
  group('ProductModel tests', () {
    test('fromJson and toJson parse attributes accurately', () {
      final json = {
        'id': 'prod-001',
        'name': 'Pupuk Organik Cair',
        'price': 25000,
        'stock': 10,
        'image_paths': ['https://example.com/img1.jpg'],
        'rating': 4.8,
        'review_count': 50,
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 'prod-001');
      expect(product.name, 'Pupuk Organik Cair');
      expect(product.price, 25000);
      expect(product.formattedPrice, 'Rp 25.000');
      expect(product.stock, 10);
      expect(product.badgeText, 'Tersedia');
      expect(product.imageUrl, 'https://example.com/img1.jpg');
    });

    test('badgeText shows Habis when stock is 0', () {
      final json = {
        'id': 'prod-002',
        'name': 'Pot Tanah Liat',
        'price': 15000,
        'stock': 0,
      };

      final product = ProductModel.fromJson(json);
      expect(product.badgeText, 'Habis');
    });
  });

  group('MarketplaceService tests', () {
    final service = MarketplaceService();

    test('fetchProducts returns filtered products by category', () async {
      final products = await service.fetchProducts(selectedCategory: 'Pupuk Organik');
      expect(products, isNotEmpty);
      for (final p in products) {
        expect(p.category, 'Pupuk Organik');
      }
    });

    test('fetchProducts filters by search query', () async {
      final products = await service.fetchProducts(searchQuery: 'neem');
      expect(products, isNotEmpty);
      expect(products.first.name.toLowerCase().contains('neem'), isTrue);
    });

    test('fetchProducts sorts by Harga Termurah', () async {
      final products = await service.fetchProducts(sortBy: 'Harga Termurah');
      expect(products.length, greaterThan(1));
      for (int i = 0; i < products.length - 1; i++) {
        expect(products[i].price, lessThanOrEqualTo(products[i + 1].price));
      }
    });
  });

  group('ProductDetailScreen widget tests', () {
    const testProduct = ProductModel(
      id: 'test-1',
      name: 'Pupuk Organik Hebat',
      description: 'Pupuk super untuk tanaman',
      storeName: 'Toko Tani Makmur',
      category: 'Pupuk Organik',
      price: 50000,
      stock: 5,
      rating: 4.9,
      reviewCount: 30,
      imageUrl: '',
    );

    testWidgets('renders all product details and + Keranjang button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailScreen(product: testProduct),
        ),
      );

      expect(find.text('Detail Produk'), findsOneWidget);
      expect(find.text('Pupuk Organik Hebat'), findsOneWidget);
      expect(find.text('Rp 50.000'), findsOneWidget);
      expect(find.text('Toko Tani Makmur'), findsOneWidget);
      expect(find.text('Deskripsi Produk'), findsOneWidget);
      expect(find.text('Pupuk super untuk tanaman'), findsOneWidget);
      expect(find.text('+ Keranjang'), findsOneWidget);
    });
  });
}

