import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProfileStatsBento extends StatelessWidget {
  const ProfileStatsBento({
    super.key,
    required this.completedDiagnosis,
    required this.activeOrders,
    required this.remainingQuota,
    required this.totalQuota,
    this.onDiagnosisStatsTap,
    this.onOrdersStatsTap,
    this.onQuotaStatsTap,
  });

  final int completedDiagnosis;
  final int activeOrders;
  final int remainingQuota;
  final int totalQuota;
  final VoidCallback? onDiagnosisStatsTap;
  final VoidCallback? onOrdersStatsTap;
  final VoidCallback? onQuotaStatsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '$completedDiagnosis',
            valueColor: AppTheme.forest,
            label: 'Diagnosis Selesai',
            onTap: onDiagnosisStatsTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            value: '$activeOrders',
            valueColor: const Color(0xFF526523),
            label: 'Pesanan Aktif',
            onTap: onOrdersStatsTap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            richValue: TextSpan(
              children: [
                TextSpan(
                  text: '$remainingQuota',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF865600),
                  ),
                ),
                TextSpan(
                  text: '/$totalQuota',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.mutedText,
                  ),
                ),
              ],
            ),
            label: 'Sisa Kuota',
            onTap: onQuotaStatsTap,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    this.value,
    this.valueColor,
    this.richValue,
    required this.label,
    this.onTap,
  });

  final String? value;
  final Color? valueColor;
  final InlineSpan? richValue;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EEE9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (richValue != null)
                RichText(text: richValue!)
              else
                Text(
                  value ?? '',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? AppTheme.forest,
                  ),
                ),
              const SizedBox(height: 3),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.mutedText,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
