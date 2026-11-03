import '../models/product_model.dart';
export '../models/product_model.dart';

class MarketplaceDemoData {
  static const List<String> categories = [
    'Semua',
    'Pupuk Organik',
    'Pestisida & Anti-Jamur',
    'Media Tanam',
    'Alat & Pot',
  ];

  static const List<ProductModel> products = [
    ProductModel(
      id: 'p-1',
      name: 'Fungisida Organik Neem Oil 250ml',
      description:
          'Formula konsentrat minyak mimba murni untuk mengendalikan jamur daun, bercak hitam, embun tepung, serta hama kutu putih secara organik dan ramah lingkungan.',
      storeName: 'Toko Kebun Berkah',
      category: 'Pestisida & Anti-Jamur',
      price: 35000,
      stock: 15,
      rating: 4.9,
      reviewCount: 128,
      imageUrl:
          'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=400&q=80',
    ),
    ProductModel(
      id: 'p-2',
      name: 'Pupuk Daun NPK Spray 500ml',
      description:
          'Pupuk cair siap semprot kaya nutrisi nitrogen, fosfor, dan kalium seimbang untuk merangsang pertumbuhan tunas baru dan mempertebal daun tanaman hias.',
      storeName: 'Toko Agro Sentosa',
      category: 'Pupuk Organik',
      price: 28000,
      stock: 20,
      rating: 4.8,
      reviewCount: 94,
      imageUrl:
          'https://images.unsplash.com/photo-1585336261026-c73c24b6f1ea?auto=format&fit=crop&w=400&q=80',
    ),
    ProductModel(
      id: 'p-3',
      name: 'Media Tanam Premium Aroid 2kg',
      description:
          'Campuran porous terdiri dari kulit pinus terfermentasi, perlite, coco chunk, dan pumice yang sangat ideal untuk Monstera, Philodendron, dan Anthurium.',
      storeName: 'Toko Hijau Tropis',
      category: 'Media Tanam',
      price: 22000,
      stock: 12,
      rating: 4.9,
      reviewCount: 210,
      imageUrl:
          'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?auto=format&fit=crop&w=400&q=80',
    ),
    ProductModel(
      id: 'p-4',
      name: 'Insektisida Nabati Ekstrak Daun 200ml',
      description:
          'Ekstrak alami dari tembakau dan daun mimba yang efektif membasmi thrips, spider mites, dan lalat buah tanpa merusak daun tanaman kesayangan.',
      storeName: 'Toko Solusi Tani',
      category: 'Pestisida & Anti-Jamur',
      price: 32500,
      stock: 4,
      rating: 4.7,
      reviewCount: 75,
      badgeText: 'Stok Terbatas',
      isLimitedStock: true,
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=400&q=80',
    ),
    ProductModel(
      id: 'p-5',
      name: 'Gunting Dahan Stainless Pruning Shear',
      description:
          'Gunting pangkas berkualitas tinggi berbahan stainless steel SK-5 yang tajam, awet, dan nyaman digenggam untuk merapikan dahan dan daun kering.',
      storeName: 'Toko Sahabat Taman',
      category: 'Alat & Pot',
      price: 45000,
      stock: 8,
      rating: 4.9,
      reviewCount: 160,
      imageUrl:
          'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=400&q=80',
    ),
    ProductModel(
      id: 'p-6',
      name: 'Pot Terakota Natural Diameter 15cm',
      description:
          'Pot tanah liat bakar dengan sirkulasi udara optimal dan lubang drainase, mencegah busuk akar pada tanaman sukulen dan aroid.',
      storeName: 'Toko Gerabah Asri',
      category: 'Alat & Pot',
      price: 18000,
      stock: 25,
      rating: 4.6,
      reviewCount: 88,
      imageUrl:
          'https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&w=400&q=80',
    ),
  ];
}
