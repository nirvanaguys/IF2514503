import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/home_demo_data.dart';

class RecommendedProductsCarousel extends StatelessWidget {
  const RecommendedProductsCarousel({
    super.key,
    required this.products,
    required this.onSeeAllTap,
    required this.onProductTap,
  });

  final List<RecommendedProduct> products;
  final VoidCallback onSeeAllTap;
  final ValueChanged<RecommendedProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Produk untuk Tanamanmu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.forest,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onSeeAllTap,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppTheme.forest,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppTheme.forest,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductItemCard(
                product: product,
                onTap: () => onProductTap(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductItemCard extends StatelessWidget {
  const _ProductItemCard({
    required this.product,
    required this.onTap,
  });

  final RecommendedProduct product;
  final VoidCallback onTap;

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
          width: 168,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EEE9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image container
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      color: AppTheme.softGreen,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(Icons.shopping_bag_outlined, color: AppTheme.forest, size: 36),
                        ),
                      ),
                    ),
                  ),
                  if (product.isAvailable)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tersedia',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppTheme.forest,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.mutedText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF101F16),
                    height: 1.25,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Color(0xFF9A6700)),
                  const SizedBox(width: 3),
                  Text(
                    product.rating.toString(),
                    style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '(${product.reviewCount})',
                    style: textTheme.labelSmall?.copyWith(color: AppTheme.mutedText),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                product.formattedPrice,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.forest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
