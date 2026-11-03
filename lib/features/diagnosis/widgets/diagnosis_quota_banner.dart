import 'package:flutter/material.dart';

class DiagnosisQuotaBanner extends StatelessWidget {
  const DiagnosisQuotaBanner({
    super.key,
    required this.onUpgradeTap,
    this.remainingQuota = 3,
    this.totalQuota = 5,
  });

  final VoidCallback onUpgradeTap;
  final int remainingQuota;
  final int totalQuota;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(21),
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF664000)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnosis AI',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF143D2A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Demo: $remainingQuota dari $totalQuota diagnosis tersedia',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onUpgradeTap,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: colorScheme.primary),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
