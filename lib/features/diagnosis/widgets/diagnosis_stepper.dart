import 'package:flutter/material.dart';

class DiagnosisStepper extends StatelessWidget {
  const DiagnosisStepper({
    super.key,
    this.currentStep = 1,
  });

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepItem(
            Icons.photo_camera_outlined,
            '1. Ambil Foto',
            currentStep >= 1,
            colorScheme,
            textTheme,
          ),
          _buildStepConnector(colorScheme),
          _buildStepItem(
            Icons.psychology_outlined,
            '2. Analisis',
            currentStep >= 2,
            colorScheme,
            textTheme,
          ),
          _buildStepConnector(colorScheme),
          _buildStepItem(
            Icons.task_alt_outlined,
            '3. Hasil',
            currentStep >= 3,
            colorScheme,
            textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24, left: 4, right: 4),
        color: colorScheme.surfaceContainer,
      ),
    );
  }

  Widget _buildStepItem(
    IconData icon,
    String label,
    bool isActive,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return SizedBox(
      width: 86,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary : colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
