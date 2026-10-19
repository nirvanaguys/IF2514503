import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/marketplace_demo_data.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    this.isWishlisted = false,
    this.onToggleWishlist,
  });

  final MarketProduct product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isWishlisted;
  final VoidCallback? onToggleWishlist;

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
              // Product Image with badges
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: Container(
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
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: product.isLimitedStock
                            ? const Color(0xFFFFDDB6)
                            : AppTheme.softGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.badgeText,
                        style: textTheme.labelSmall?.copyWith(
                          color: product.isLimitedStock
                              ? const Color(0xFF664000)
                              : AppTheme.forest,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onToggleWishlist,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isWishlisted ? const Color(0xFFC62828) : AppTheme.mutedText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  product.storeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppTheme.mutedText,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              if (product.isVerifiedStore) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 13,
                                  color: AppTheme.forest,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF101F16),
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 34,
                            child: FilledButton.icon(
                              onPressed: onAddToCart,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.softGreen,
                                foregroundColor: AppTheme.forest,
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.add_shopping_cart, size: 16),
                              label: const Text(
                                '+ Keranjang',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
