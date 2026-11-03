class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final String orderId;
  final int rating;
  final String? reviewText;
  final String? displayName;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.orderId,
    required this.rating,
    this.reviewText,
    this.displayName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // displayName bisa dari join profiles
    final profileData = json['profiles'] as Map<String, dynamic>?;
    final displayName =
        profileData?['display_name'] as String? ??
        (json['display_name'] as String?);

    return ReviewModel(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      reviewText: json['review_text'] as String?,
      displayName: displayName,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'user_id': userId,
      'order_id': orderId,
      'rating': rating,
      if (reviewText != null && reviewText!.isNotEmpty)
        'review_text': reviewText,
    };
  }
}
