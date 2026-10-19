
import 'dart:io';

import 'package:flutter/material.dart';


class ImagePreviewCard extends StatelessWidget {
  const ImagePreviewCard({
    super.key,
    required this.image,
    required this.selectedCategory,
    required this.onRemove,
    required this.onAnalyze,
  });

  final File image;
  final String selectedCategory;
  final VoidCallback onRemove;
  final VoidCallback onAnalyze;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Preview foto',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              image,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  alignment: Alignment.center,
                  color: colorScheme.surfaceContainerLow,
                  child: const Text('Foto tidak dapat ditampilkan.'),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kategori yang dipilih: $selectedCategory',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onAnalyze,
              icon: const Icon(Icons.search),
              label: const Text('Lanjut ke Analisis (demo)'),
            ),
          ),
        ],
      ),
    );
  }
}
