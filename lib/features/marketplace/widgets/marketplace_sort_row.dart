import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MarketplaceSortRow extends StatelessWidget {
  const MarketplaceSortRow({
    super.key,
    required this.currentSort,
    required this.productCount,
    required this.onSortTap,
  });

  final String currentSort;
  final int productCount;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onSortTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              children: [
                const Icon(
                  Icons.filter_list,
                  size: 18,
                  color: AppTheme.forest,
                ),
                const SizedBox(width: 6),
                Text(
                  'Urutkan: ',
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  currentSort,
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.forest,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(
                  Icons.expand_more,
                  size: 18,
                  color: AppTheme.mutedText,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$productCount Produk',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.forest,
            ),
          ),
        ),
      ],
    );
  }
}
