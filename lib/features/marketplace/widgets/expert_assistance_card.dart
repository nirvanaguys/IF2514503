import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ExpertAssistanceCard extends StatelessWidget {
  const ExpertAssistanceCard({
    super.key,
    required this.onDiagnoseTap,
  });

  final VoidCallback onDiagnoseTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.forest,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bingung pilih pupuk tepat?',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF143D2A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Diagnosa tanamanmu dulu agar rekomendasi obat lebih akurat!',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDiagnoseTap,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.forest,
            ),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
