import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daunku_app/features/cart/models/cart_item_model.dart';
import 'package:daunku_app/features/cart/screens/cart_screen.dart';
import 'package:daunku_app/features/cart/services/cart_service.dart';
import 'package:daunku_app/features/checkout/models/address_model.dart';
import 'package:daunku_app/features/checkout/screens/checkout_screen.dart';
import 'package:daunku_app/features/checkout/services/checkout_service.dart';
import 'package:daunku_app/features/marketplace/models/product_model.dart';
import 'package:daunku_app/features/orders/screens/orders_screen.dart';

void main() {
  const dummyProduct1 = ProductModel(
    id: 'prod-1',
    name: 'Pupuk Kompos',
    price: 20000,
    stock: 5,
    rating: 4.8,
    reviewCount: 10,
    storeName: 'Toko Tani',
    category: 'Pupuk Organik',
    imageUrl: '',
  );

  const dummyProduct2 = ProductModel(
    id: 'prod-2',
    name: 'Fungisida Daun',
    price: 30000,
    stock: 10,
    rating: 4.9,
    reviewCount: 20,
    storeName: 'Toko Agro',
    category: 'Pestisida',
    imageUrl: '',
  );

  group('CartService tests', () {
    final cartService = CartService();

    setUp(() async {
      await cartService.clearCart(null);
    });

    test('adds items and calculates subtotal/total correctly', () async {
      await cartService.addToCart(null, dummyProduct1, quantity: 2); // 40.000
      await cartService.addToCart(null, dummyProduct2, quantity: 1); // 30.000

      expect(cartService.items.length, 2);
      expect(cartService.totalAmount, 70000);
      expect(cartService.formattedTotalAmount, 'Rp 70.000');
    });

    test('clamps quantity to product stock limit', () async {
      await cartService.addToCart(null, dummyProduct1, quantity: 10);
      expect(cartService.items.first.quantity, dummyProduct1.stock);
    });

    test('updates quantity and removes item when 0', () async {
      await cartService.addToCart(null, dummyProduct1, quantity: 2);
      await cartService.updateQuantity(null, dummyProduct1.id, 4);
      expect(cartService.items.first.quantity, 4);

      await cartService.updateQuantity(null, dummyProduct1.id, 0);
      expect(cartService.items.isEmpty, isTrue);
    });
  });

  group('AddressModel tests', () {
    test('fullAddressText formats correctly', () {
      const address = AddressModel(
        id: '1',
        userId: 'u1',
        recipientName: 'Budi',
        phone: '08123',
        addressLine: 'Jl. Merdeka No. 1',
        city: 'Bandung',
        province: 'Jawa Barat',
        postalCode: '40111',
      );

      expect(address.fullAddressText, 'Jl. Merdeka No. 1, Bandung, Jawa Barat 40111');
    });
  });

  group('CheckoutService and OrderModel tests', () {
    final checkoutService = CheckoutService();

    test('createOrder calculates amounts and creates order structure', () async {
      const address = AddressModel(
        id: 'addr-1',
        userId: 'user-123',
        recipientName: 'Wisnu',
        phone: '0812345',
        addressLine: 'Jl. Melati 10',
        city: 'Jakarta',
        province: 'DKI Jakarta',
      );

      const cartItem = CartItemModel(
        id: 'c-1',
        userId: 'user-123',
        productId: 'prod-1',
        quantity: 2,
        product: dummyProduct1,
      );

      final order = await checkoutService.createOrder(
        userId: 'user-123',
        address: address,
        items: [cartItem],
        shippingCost: 15000,
      );

      expect(order.subtotal, 40000);
      expect(order.shippingCost, 15000);
      expect(order.total, 55000);
      expect(order.formattedTotal, 'Rp 55.000');
      expect(order.items.first.productName, 'Pupuk Kompos');
      expect(order.statusBadgeText, 'Menunggu Pembayaran');
    });
  });

  group('Cart, Checkout, and Orders UI screen tests', () {
    testWidgets('CartScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CartScreen()),
      );
      expect(find.text('Keranjang Belanja'), findsOneWidget);
    });

    testWidgets('CheckoutScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CheckoutScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Checkout Pesanan'), findsOneWidget);
      expect(find.text('Metode Pembayaran'), findsOneWidget);
    });

    testWidgets('OrdersScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OrdersScreen()),
      );
      expect(find.text('Pesanan Saya'), findsOneWidget);
      expect(find.text('Menunggu Bayar'), findsOneWidget);
    });
  });
}
