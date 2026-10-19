class RecommendedProduct {
  const RecommendedProduct({
    required this.id,
    required this.name,
    required this.storeName,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String storeName;
  final int price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final bool isAvailable;

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

class RecentDiagnosisItem {
  const RecentDiagnosisItem({
    required this.plantName,
    required this.date,
    required this.diseaseName,
    required this.confidenceScore,
    required this.imageUrl,
    this.isDemo = true,
  });

  final String plantName;
  final String date;
  final String diseaseName;
  final int confidenceScore;
  final String imageUrl;
  final bool isDemo;
}

class HomeDemoData {
  static const String userName = 'Wisnu';
  static const String weatherTemperature = '29°C';
  static const String weatherCondition = 'Cerah';
  static const int usedQuota = 3;
  static const int totalQuota = 5;

  static const String dailyTip =
      'Hindari menyiram daun monstera di sore hari agar kelembapan tidak memicu jamur bercak daun.';

  static const List<RecommendedProduct> recommendedProducts = [
    RecommendedProduct(
      id: 'prod-1',
      name: 'Fungisida Organik Neem Oil 250ml',
      storeName: 'Kebun Berkah',
      price: 35000,
      rating: 4.9,
      reviewCount: 128,
      imageUrl:
          'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=400&q=80',
    ),
    RecommendedProduct(
      id: 'prod-2',
      name: 'Pupuk Daun NPK Spray 500ml',
      storeName: 'Agro Sentosa',
      price: 28000,
      rating: 4.8,
      reviewCount: 94,
      imageUrl:
          'https://images.unsplash.com/photo-1585336261026-c73c24b6f1ea?auto=format&fit=crop&w=400&q=80',
    ),
    RecommendedProduct(
      id: 'prod-3',
      name: 'Media Tanam Premium Aroid 5L',
      storeName: 'Rumah Flora',
      price: 45000,
      rating: 5.0,
      reviewCount: 62,
      imageUrl:
          'https://images.unsplash.com/photo-1463936575829-25148e1db1b8?auto=format&fit=crop&w=400&q=80',
    ),
  ];

  static const RecentDiagnosisItem recentDiagnosis = RecentDiagnosisItem(
    plantName: 'Monstera Deliciosa',
    date: 'Senin, 25 Sep 2026',
    diseaseName: 'Bercak Daun',
    confidenceScore: 87,
    imageUrl:
        'https://images.unsplash.com/photo-1614594975525-e45190c55d0b?auto=format&fit=crop&w=400&q=80',
  );
}
