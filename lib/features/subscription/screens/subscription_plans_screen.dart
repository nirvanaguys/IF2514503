import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../models/subscription_models.dart';
import '../services/subscription_service.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final _subscriptionService = SubscriptionService();
  final _authService = AuthService();

  List<SubscriptionPlanModel> _plans = [];
  UserSubscriptionModel? _activeSub;
  QuotaInfo _quotaInfo = QuotaInfo.freeDefault;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = _authService.currentUser;
    final plans = await _subscriptionService.fetchPlans();

    UserSubscriptionModel? activeSub;
    QuotaInfo quotaInfo = QuotaInfo.freeDefault;

    if (user != null) {
      activeSub = await _subscriptionService.fetchActiveSubscription(user.id);
      quotaInfo = await _subscriptionService.getQuotaInfo(user.id);
    }

    if (mounted) {
      setState(() {
        _plans = plans;
        _activeSub = activeSub;
        _quotaInfo = quotaInfo;
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleSubscribe(SubscriptionPlanModel plan) async {
    final user = _authService.currentUser;
    if (user == null) {
      _showMessage('Silakan masuk ke akun Anda terlebih dahulu.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Berlangganan ${plan.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${plan.formattedPrice}${plan.periodLabel}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.forest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan.description ?? '',
              style: const TextStyle(fontSize: 13, color: AppTheme.mutedText),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF9A6700)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pembayaran saat ini dalam mode demo/sandbox.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF9A6700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forest,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Aktifkan Sekarang'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      await _subscriptionService.subscribe(
        userId: user.id,
        plan: plan,
        paymentReference:
            'DEMO-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.softGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: AppTheme.forest,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Premium Aktif! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Paket ${plan.name} berhasil diaktifkan. '
                'Nikmati kuota diagnosis yang lebih banyak!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.mutedText),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forest,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Lanjutkan'),
            ),
          ],
        ),
      );

      _loadData();
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Paket Premium DaunKu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101F16),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppTheme.forest,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status kuota saat ini
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _quotaInfo.isPremium
                                    ? const Color(0xFFFFDDB6)
                                    : AppTheme.softGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _quotaInfo.isPremium
                                    ? Icons.workspace_premium
                                    : Icons.eco,
                                color: _quotaInfo.isPremium
                                    ? const Color(0xFF664000)
                                    : AppTheme.forest,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _quotaInfo.isPremium
                                        ? 'Premium Aktif'
                                        : 'Paket Gratis',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (_activeSub != null)
                                    Text(
                                      '${_activeSub!.planName ?? "Premium"} — '
                                      '${_activeSub!.daysRemaining} hari tersisa',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.mutedText,
                                      ),
                                    )
                                  else
                                    Text(
                                      'Kuota: ${_quotaInfo.remaining}/${_quotaInfo.quotaLimit} diagnosis tersisa',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.mutedText,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!_quotaInfo.isPremium) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _quotaInfo.quotaLimit > 0
                                  ? (_quotaInfo.usedCount /
                                            _quotaInfo.quotaLimit)
                                        .clamp(0.0, 1.0)
                                  : 0.0,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE0F2E4),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.forest,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Judul paket
                  const Text(
                    'Pilih Paket Premium',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF101F16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tingkatkan pengalaman DaunKu dengan kuota diagnosis lebih banyak.',
                    style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
                  ),
                  const SizedBox(height: 16),

                  // Daftar paket
                  ..._plans.map((plan) => _buildPlanCard(plan)),

                  const SizedBox(height: 20),

                  // Info fitur premium
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Keuntungan Premium',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _benefitRow(
                          Icons.auto_awesome,
                          'Kuota diagnosis lebih banyak atau tanpa batas',
                        ),
                        _benefitRow(
                          Icons.history,
                          'Riwayat diagnosis tersimpan lengkap',
                        ),
                        _benefitRow(
                          Icons.support_agent,
                          'Prioritas konsultasi ahli tanaman',
                        ),
                        _benefitRow(
                          Icons.discount,
                          'Diskon spesial di marketplace DaunKu',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanModel plan) {
    final isCurrentPlan = _activeSub != null && _activeSub!.planId == plan.id;
    final isPopular = plan.slug == 'yearly';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppTheme.forest : const Color(0xFFE8EEE9),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppTheme.forest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: const Text(
                '🏆 HEMAT PALING BANYAK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.softGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Aktif',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forest,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      plan.formattedPrice,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forest,
                      ),
                    ),
                    Text(
                      plan.periodLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.isUnlimited
                      ? '✓ Diagnosis tanpa batas'
                      : '✓ ${plan.diagnosisQuota} diagnosis per bulan',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333333),
                  ),
                ),
                if (plan.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    plan.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () => _handleSubscribe(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPlan
                          ? AppTheme.mutedText
                          : AppTheme.forest,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrentPlan ? 'Paket Aktif' : 'Pilih Paket Ini',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.forest),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }
}
