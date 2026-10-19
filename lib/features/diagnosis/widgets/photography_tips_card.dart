import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PhotographyTipsCard extends StatelessWidget {
  const PhotographyTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 20, color: AppTheme.forest),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tips foto yang bagus',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.forest,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBulletPoint(
            'Pastikan pencahayaan cukup terang dan daun terlihat jelas.',
            colorScheme,
            textTheme,
          ),
          _buildBulletPoint(
            'Fokuskan pada bagian daun yang berbercak, menguning, atau layu.',
            colorScheme,
            textTheme,
          ),
          _buildBulletPoint(
            'Hindari foto yang buram atau diambil terlalu jauh.',
            colorScheme,
            textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•  ',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: AppTheme.mutedText,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
