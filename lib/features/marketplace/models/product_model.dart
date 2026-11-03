class ProductModel {
  final String id;
  final String name;
  final String description;
  final String storeName;
  final String category;
  final String? categoryId;
  final String? sellerId;
  final int price;
  final int stock;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> images;
  final String badgeText;
  final bool isLimitedStock;
  final bool isVerifiedStore;
  final bool isPublished;

  const ProductModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.storeName,
    required this.category,
    this.categoryId,
    this.sellerId,
    required this.price,
    this.stock = 10,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.images = const [],
    this.badgeText = 'Tersedia',
    this.isLimitedStock = false,
    this.isVerifiedStore = true,
    this.isPublished = true,
  });

  String get formattedPrice {
    final str = price.toString();
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagePaths = (json['image_paths'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final firstImage = imagePaths.isNotEmpty
        ? imagePaths.first
        : (json['image_url'] as String? ?? '');

    final stock = json['stock'] as int? ?? 0;

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Produk Tanaman',
      description: json['description'] as String? ?? '',
      storeName: json['seller_profiles']?['store_name'] as String? ??
          (json['store_name'] as String? ?? 'Toko DaunKu'),
      category: json['categories']?['name'] as String? ??
          (json['category'] as String? ?? 'Semua'),
      categoryId: json['category_id'] as String?,
      sellerId: json['seller_id'] as String?,
      price: json['price'] as int? ?? 0,
      stock: stock,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: json['review_count'] as int? ?? 0,
      imageUrl: firstImage,
      images: imagePaths,
      badgeText: stock <= 0
          ? 'Habis'
          : (stock < 5 ? 'Stok Terbatas' : 'Tersedia'),
      isLimitedStock: stock > 0 && stock < 5,
      isVerifiedStore: true,
      isPublished: json['is_published'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image_paths': images.isNotEmpty ? images : [imageUrl],
      if (categoryId != null) 'category_id': categoryId,
      if (sellerId != null) 'seller_id': sellerId,
      'is_published': isPublished,
    };
  }

  ProductModel copyWith({
    String? name,
    String? description,
    String? storeName,
    String? category,
    String? categoryId,
    String? sellerId,
    int? price,
    int? stock,
    double? rating,
    int? reviewCount,
    String? imageUrl,
    List<String>? images,
    String? badgeText,
    bool? isLimitedStock,
    bool? isVerifiedStore,
    bool? isPublished,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      storeName: storeName ?? this.storeName,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      sellerId: sellerId ?? this.sellerId,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      badgeText: badgeText ?? this.badgeText,
      isLimitedStock: isLimitedStock ?? this.isLimitedStock,
      isVerifiedStore: isVerifiedStore ?? this.isVerifiedStore,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

/// Typedef alias untuk menjaga kompatibilitas dengan MarketProduct yang sudah ada
typedef MarketProduct = ProductModel;

