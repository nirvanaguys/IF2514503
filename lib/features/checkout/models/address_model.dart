class AddressModel {
  final String id;
  final String userId;
  final String recipientName;
  final String phone;
  final String addressLine;
  final String city;
  final String province;
  final String? postalCode;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.province,
    this.postalCode,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  String get fullAddressText =>
      '$addressLine, $city, $province ${postalCode ?? ''}'.trim();

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      recipientName: json['recipient_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addressLine: json['address_line'] as String? ?? '',
      city: json['city'] as String? ?? '',
      province: json['province'] as String? ?? '',
      postalCode: json['postal_code'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'recipient_name': recipientName,
      'phone': phone,
      'address_line': addressLine,
      'city': city,
      'province': province,
      if (postalCode != null) 'postal_code': postalCode,
      'is_default': isDefault,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  AddressModel copyWith({
    String? recipientName,
    String? phone,
    String? addressLine,
    String? city,
    String? province,
    String? postalCode,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id,
      userId: userId,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

