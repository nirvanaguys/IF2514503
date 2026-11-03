class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? avatarPath;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.avatarPath,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json, {String fallbackEmail = ''}) {
    return UserProfile(
      id: json['id'] as String,
      displayName: (json['display_name'] as String?)?.isNotEmpty == true
          ? json['display_name'] as String
          : (fallbackEmail.isNotEmpty ? fallbackEmail.split('@').first : 'Pengguna DaunKu'),
      email: fallbackEmail.isNotEmpty ? fallbackEmail : (json['email'] as String? ?? ''),
      avatarPath: json['avatar_path'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      if (avatarPath != null) 'avatar_path': avatarPath,
      if (phone != null) 'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? avatarPath,
    String? phone,
  }) {
    return UserProfile(
      id: id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

