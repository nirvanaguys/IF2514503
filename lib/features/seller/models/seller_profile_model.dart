class SellerProfileModel {
  final String id;
  final String userId;
  final String storeName;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SellerProfileModel({
    required this.id,
    required this.userId,
    required this.storeName,
    this.description,
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';

  factory SellerProfileModel.fromJson(Map<String, dynamic> json) {
    return SellerProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? 'Toko Saya',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'store_name': storeName,
      if (description != null) 'description': description,
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  SellerProfileModel copyWith({
    String? storeName,
    String? description,
    String? status,
  }) {
    return SellerProfileModel(
      id: id,
      userId: userId,
      storeName: storeName ?? this.storeName,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

