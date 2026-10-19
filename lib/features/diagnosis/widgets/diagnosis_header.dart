import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DiagnosisHeader extends StatelessWidget {
  const DiagnosisHeader({
    super.key,
    required this.onNotificationTap,
    this.onProfileTap,
  });

  final VoidCallback onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white.withValues(alpha: 0.92),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.eco, color: AppTheme.forest, size: 27),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DaunKu',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forest,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Diagnosis Tanaman',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Notifikasi',
                onPressed: onNotificationTap,
                icon: const Icon(Icons.notifications_outlined),
              ),
              GestureDetector(
                onTap: onProfileTap,
                child: const CircleAvatar(
                  radius: 17,
                  backgroundColor: AppTheme.softGreen,
                  child: Icon(Icons.person_outline, color: AppTheme.forest),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
