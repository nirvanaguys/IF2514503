import '../../marketplace/models/product_model.dart';

class CartItemModel {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final ProductModel product;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CartItemModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.product,
    this.createdAt,
    this.updatedAt,
  });

  int get subtotal => product.price * quantity;

  String get formattedSubtotal {
    final str = subtotal.toString();
    final buffer = StringBuffer('Rp ');
    final len = str.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json, {ProductModel? productFallback}) {
    final productData = json['products'] != null
        ? ProductModel.fromJson(json['products'] as Map<String, dynamic>)
        : (productFallback ??
            ProductModel(
              id: json['product_id'] as String,
              name: 'Produk Tanaman',
              storeName: 'Toko DaunKu',
              category: 'Semua',
              price: json['price'] as int? ?? 0,
              rating: 5.0,
              reviewCount: 0,
              imageUrl: '',
            ));

    return CartItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int? ?? 1,
      product: productData,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  CartItemModel copyWith({
    int? quantity,
    ProductModel? product,
  }) {
    return CartItemModel(
      id: id,
      userId: userId,
      productId: productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

