import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

class ProductReviewsSection extends StatefulWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  State<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends State<ProductReviewsSection> {
  final _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    final reviews = await _reviewService.fetchProductReviews(widget.productId);
    if (mounted) {
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ulasan Pembeli',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101F16),
                ),
              ),
              if (_reviews.isNotEmpty)
                Text(
                  '${_reviews.length} ulasan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_reviews.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                child: Text(
                  'Belum ada ulasan untuk produk ini.',
                  style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
                ),
              ),
            )
          else
            ..._reviews.take(5).map((review) => _buildReviewCard(review)),
          if (_reviews.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  // Bisa diperluas untuk halaman ulasan lengkap
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Halaman ulasan lengkap akan hadir segera.',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Lihat semua ${_reviews.length} ulasan',
                  style: const TextStyle(
                    color: AppTheme.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.pageBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.softGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      (review.displayName ?? 'P').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.forest,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.displayName ?? 'Pembeli',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Bintang
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 16,
                      color: index < review.rating
                          ? const Color(0xFFFFA000)
                          : const Color(0xFFCCCCCC),
                    );
                  }),
                ),
              ],
            ),
            if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.reviewText!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF333333),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
