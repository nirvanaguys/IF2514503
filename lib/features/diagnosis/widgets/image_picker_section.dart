
import 'package:flutter/material.dart';
import 'package:daunku_app/core/theme/app_theme.dart';

class ImagePickerSection extends StatelessWidget {
  const ImagePickerSection({
    super.key,
    required this.isPickingImage,
    required this.onCameraTap,
    required this.onGalleryTap,
  });

  final bool isPickingImage;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        _PhotoOption(
          colorScheme: colorScheme,
          textTheme: textTheme,
          icon: Icons.photo_camera_outlined,
          title: 'Ambil Foto Langsung',
          description:
              'Gunakan kamera untuk memfoto daun yang bermasalah.',
          isRecommended: true,
          isPickingImage: isPickingImage,
          onTap: onCameraTap,
        ),
        const SizedBox(height: 12),
        _PhotoOption(
          colorScheme: colorScheme,
          textTheme: textTheme,
          icon: Icons.collections_outlined,
          title: 'Pilih dari Galeri',
          description:
              'Pilih foto tanaman yang sudah tersimpan di perangkat.',
          isRecommended: false,
          isPickingImage: isPickingImage,
          onTap: onGalleryTap,
        ),
        if (isPickingImage) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}

class _PhotoOption extends StatelessWidget {
  const _PhotoOption({
    required this.colorScheme,
    required this.textTheme,
    required this.icon,
    required this.title,
    required this.description,
    required this.isRecommended,
    required this.isPickingImage,
    required this.onTap,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final IconData icon;
  final String title;
  final String description;
  final bool isRecommended;
  final bool isPickingImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isPickingImage ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRecommended
                  ? colorScheme.primary.withValues(alpha: 0.28)
                  : const Color(0xFFE3E9E4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 29,
                  color: AppTheme.forest,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isRecommended
                                  ? AppTheme.forest
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          size: 19,
                          color: AppTheme.mutedText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 16,
                            color: AppTheme.forest,
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Direkomendasikan',
                              style: TextStyle(
                                color: AppTheme.forest,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
