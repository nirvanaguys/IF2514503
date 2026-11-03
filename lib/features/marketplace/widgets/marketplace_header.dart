import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../cart/services/cart_service.dart';

class MarketplaceHeader extends StatelessWidget {
  const MarketplaceHeader({
    super.key,
    required this.onNotificationTap,
    this.onProfileTap,
    this.onCartTap,
  });

  final VoidCallback onNotificationTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onCartTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cartService = CartService();

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
                child: const Icon(Icons.eco, color: AppTheme.forest, size: 26),
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
                    const SizedBox(height: 2),
                    Text(
                      'Marketplace Pertanian',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.mutedText,
                      ),
                    ),
                  ],
                ),
              ),

              // Cart Button dengan Badge Counter
              ValueListenableBuilder<int>(
                valueListenable: cartService.cartCountNotifier,
                builder: (context, count, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Keranjang Belanja',
                        onPressed: onCartTap,
                        icon: const Icon(Icons.shopping_cart_outlined, color: AppTheme.forest),
                      ),
                      if (count > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFC62828),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '$count',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              // Notification Button
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'Notifikasi',
                    onPressed: onNotificationTap,
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC62828),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),

              // Profile Avatar
              GestureDetector(
                onTap: onProfileTap,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.softGreen,
                  child: Icon(Icons.person, color: AppTheme.forest, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
