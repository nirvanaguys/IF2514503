class MarketProduct {
  const MarketProduct({
    required this.id,
    required this.name,
    required this.storeName,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.badgeText = 'Tersedia',
    this.isLimitedStock = false,
    this.isVerifiedStore = true,
  });

  final String id;
  final String name;
  final String storeName;
  final String category;
  final int price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String badgeText;
  final bool isLimitedStock;
  final bool isVerifiedStore;

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
}

class MarketplaceDemoData {
  static const List<String> categories = [
    'Semua',
    'Pupuk Organik',
    'Pestisida & Anti-Jamur',
    'Media Tanam',
    'Alat & Pot',
  ];

  static const List<MarketProduct> products = [
    MarketProduct(
      id: 'p-1',
      name: 'Fungisida Organik Neem Oil 250ml',
      storeName: 'Toko Kebun Berkah',
      category: 'Pestisida & Anti-Jamur',
      price: 35000,
      rating: 4.9,
      reviewCount: 128,
      imageUrl:
          'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=400&q=80',
    ),
    MarketProduct(
      id: 'p-2',
      name: 'Pupuk Daun NPK Spray 500ml',
      storeName: 'Toko Agro Sentosa',
      category: 'Pupuk Organik',
      price: 28000,
      rating: 4.8,
      reviewCount: 94,
      imageUrl:
          'https://images.unsplash.com/photo-1585336261026-c73c24b6f1ea?auto=format&fit=crop&w=400&q=80',
    ),
    MarketProduct(
      id: 'p-3',
      name: 'Media Tanam Premium Aroid 2kg',
      storeName: 'Toko Hijau Tropis',
      category: 'Media Tanam',
      price: 22000,
      rating: 4.9,
      reviewCount: 210,
      imageUrl:
          'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?auto=format&fit=crop&w=400&q=80',
    ),
    MarketProduct(
      id: 'p-4',
      name: 'Insektisida Nabati Ekstrak Daun 200ml',
      storeName: 'Toko Solusi Tani',
      category: 'Pestisida & Anti-Jamur',
      price: 32500,
      rating: 4.7,
      reviewCount: 75,
      badgeText: 'Stok Terbatas',
      isLimitedStock: true,
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
    ),
    MarketProduct(
      id: 'p-5',
      name: 'Gunting Dahan Stainless Pruning Shear',
      storeName: 'Toko Alat Tani',
      category: 'Alat & Pot',
      price: 45000,
      rating: 4.8,
      reviewCount: 115,
      imageUrl:
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=400&q=80',
    ),
    MarketProduct(
      id: 'p-6',
      name: 'Pupuk Kandang Fermentasi Halus 5kg',
      storeName: 'Toko Organik Makmur',
      category: 'Pupuk Organik',
      price: 18000,
      rating: 4.9,
      reviewCount: 180,
      imageUrl:
          'https://images.unsplash.com/photo-1592417817098-8f3d69102a5c?auto=format&fit=crop&w=400&q=80',
    ),
  ];
}
