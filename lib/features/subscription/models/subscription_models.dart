class SubscriptionPlanModel {
  final String id;
  final String name;
  final String slug;
  final int price;
  final int durationDays;
  final int diagnosisQuota; // -1 = unlimited
  final String? description;
  final bool isActive;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.price,
    required this.durationDays,
    required this.diagnosisQuota,
    this.description,
    this.isActive = true,
  });

  bool get isUnlimited => diagnosisQuota == -1;

  String get formattedPrice {
    final str = price.toString();
    final buffer = StringBuffer('Rp ');
    final len = str.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String get periodLabel {
    if (durationDays <= 31) return '/bulan';
    if (durationDays <= 366) return '/tahun';
    return '/$durationDays hari';
  }

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      durationDays: json['duration_days'] as int? ?? 30,
      diagnosisQuota: json['diagnosis_quota'] as int? ?? 10,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

class UserSubscriptionModel {
  final String id;
  final String userId;
  final String planId;
  final String status;
  final DateTime startsAt;
  final DateTime expiresAt;
  final String? paymentReference;
  final String? planName;

  const UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    required this.status,
    required this.startsAt,
    required this.expiresAt,
    this.paymentReference,
    this.planName,
  });

  bool get isActive => status == 'active' && expiresAt.isAfter(DateTime.now());

  int get daysRemaining {
    final diff = expiresAt.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    final planData = json['subscription_plans'] as Map<String, dynamic>?;

    return UserSubscriptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      planId: json['plan_id'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      paymentReference: json['payment_reference'] as String?,
      planName: planData?['name'] as String?,
    );
  }
}

class QuotaInfo {
  final int quotaLimit;
  final int usedCount;
  final int remaining;
  final bool isPremium;

  const QuotaInfo({
    required this.quotaLimit,
    required this.usedCount,
    required this.remaining,
    required this.isPremium,
  });

  factory QuotaInfo.fromJson(Map<String, dynamic> json) {
    return QuotaInfo(
      quotaLimit: json['quota_limit'] as int? ?? 10,
      usedCount: json['used_count'] as int? ?? 0,
      remaining: json['remaining'] as int? ?? 10,
      isPremium: json['is_premium'] as bool? ?? false,
    );
  }

  /// Kuota default untuk pengguna gratis yang belum login
  static const QuotaInfo freeDefault = QuotaInfo(
    quotaLimit: 10,
    usedCount: 0,
    remaining: 10,
    isPremium: false,
  );
}
