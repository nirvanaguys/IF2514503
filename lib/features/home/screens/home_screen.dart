import 'package:flutter/material.dart';

import '../data/home_demo_data.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onStartDiagnosis,
    this.onOpenMarketplace,
    this.onOpenProfile,
  });

  final VoidCallback? onStartDiagnosis;
  final VoidCallback? onOpenMarketplace;
  final VoidCallback? onOpenProfile;

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              onNotificationTap: () =>
                  _showMessage(context, 'Notifikasi belum tersedia.'),
              onProfileTap: onOpenProfile,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Sapaan & Cuaca
                    const GreetingWeatherSection(
                      userName: HomeDemoData.userName,
                      temperature: HomeDemoData.weatherTemperature,
                      weatherCondition: HomeDemoData.weatherCondition,
                    ),
                    const SizedBox(height: 16),

                    // 2. Hero Diagnosis Card
                    HeroDiagnosisCard(
                      onDiagnosisTap: () {
                        onStartDiagnosis?.call();
                      },
                    ),
                    const SizedBox(height: 14),

                    // 3. Kuota Diagnosis Card
                    HomeQuotaCard(
                      usedQuota: HomeDemoData.usedQuota,
                      totalQuota: HomeDemoData.totalQuota,
                      onUpgradeTap: () => _showMessage(
                        context,
                        'Fitur Upgrade kuota belum tersedia pada versi demo.',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Produk Rekomendasi
                    RecommendedProductsCarousel(
                      products: HomeDemoData.recommendedProducts,
                      onSeeAllTap: () => onOpenMarketplace?.call(),
                      onProductTap: (product) => onOpenMarketplace?.call(),
                    ),
                    const SizedBox(height: 20),

                    // 5. Diagnosis Terakhir
                    RecentDiagnosisCard(
                      item: HomeDemoData.recentDiagnosis,
                      onSeeHistoryTap: () => _showMessage(
                        context,
                        'Riwayat lengkap akan tersedia pada tahap riwayat.',
                      ),
                      onTap: () => _showMessage(
                        context,
                        'Detail riwayat diagnosis demo: Monstera Deliciosa.',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. Tip Edukasi Cepat
                    const DailyCareTipCard(
                      tipText: HomeDemoData.dailyTip,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
