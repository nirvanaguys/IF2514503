import 'package:flutter/material.dart';

import '../../auth/services/auth_service.dart';
import '../../subscription/models/subscription_models.dart';
import '../../subscription/screens/subscription_plans_screen.dart';
import '../../subscription/services/subscription_service.dart';
import '../data/home_demo_data.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onStartDiagnosis,
    this.onOpenMarketplace,
    this.onOpenProfile,
  });

  final VoidCallback? onStartDiagnosis;
  final VoidCallback? onOpenMarketplace;
  final VoidCallback? onOpenProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _subscriptionService = SubscriptionService();
  QuotaInfo _quotaInfo = QuotaInfo.freeDefault;

  @override
  void initState() {
    super.initState();
    _loadQuota();
  }

  Future<void> _loadQuota() async {
    final user = _authService.currentUser;
    if (user != null) {
      final info = await _subscriptionService.getQuotaInfo(user.id);
      if (mounted) {
        setState(() => _quotaInfo = info);
      }
    }
  }

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
              onProfileTap: widget.onOpenProfile,
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
                        widget.onStartDiagnosis?.call();
                      },
                    ),
                    const SizedBox(height: 14),

                    // 3. Kuota Diagnosis Card (data nyata)
                    HomeQuotaCard(
                      usedQuota: _quotaInfo.remaining,
                      totalQuota: _quotaInfo.quotaLimit,
                      onUpgradeTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SubscriptionPlansScreen(),
                              ),
                            )
                            .then((_) => _loadQuota());
                      },
                    ),
                    const SizedBox(height: 20),

                    // 4. Produk Rekomendasi
                    RecommendedProductsCarousel(
                      products: HomeDemoData.recommendedProducts,
                      onSeeAllTap: () => widget.onOpenMarketplace?.call(),
                      onProductTap: (product) =>
                          widget.onOpenMarketplace?.call(),
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
                    const DailyCareTipCard(tipText: HomeDemoData.dailyTip),
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
