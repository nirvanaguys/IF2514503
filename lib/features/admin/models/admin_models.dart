class ProductReportModel {
  final String id;
  final String productId;
  final String reporterId;
  final String reason;
  final String? description;
  final String status; // pending, reviewed, dismissed
  final DateTime createdAt;

  // Joined data
  final String? productName;
  final String? reporterName;

  const ProductReportModel({
    required this.id,
    required this.productId,
    required this.reporterId,
    required this.reason,
    this.description,
    this.status = 'pending',
    required this.createdAt,
    this.productName,
    this.reporterName,
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu Ditinjau';
      case 'reviewed':
        return 'Sudah Ditindak';
      case 'dismissed':
        return 'Diabaikan';
      default:
        return status;
    }
  }

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    final productData = json['products'] as Map<String, dynamic>?;
    final reporterData = json['profiles'] as Map<String, dynamic>?;

    return ProductReportModel(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? '',
      reporterId: json['reporter_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      productName: productData?['name'] as String?,
      reporterName: reporterData?['display_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'reporter_id': reporterId,
      'reason': reason,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}

class ModerationActionModel {
  final String id;
  final String? reportId;
  final String adminId;
  final String? productId;
  final String actionType;
  final String? notes;
  final DateTime createdAt;

  const ModerationActionModel({
    required this.id,
    this.reportId,
    required this.adminId,
    this.productId,
    required this.actionType,
    this.notes,
    required this.createdAt,
  });

  String get actionLabel {
    switch (actionType) {
      case 'deactivate_product':
        return 'Produk Dinonaktifkan';
      case 'warn_seller':
        return 'Peringatan Penjual';
      case 'dismiss_report':
        return 'Laporan Diabaikan';
      default:
        return actionType;
    }
  }

  factory ModerationActionModel.fromJson(Map<String, dynamic> json) {
    return ModerationActionModel(
      id: json['id'] as String,
      reportId: json['report_id'] as String?,
      adminId: json['admin_id'] as String? ?? '',
      productId: json['product_id'] as String?,
      actionType: json['action_type'] as String? ?? '',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Alasan laporan yang tersedia
class ReportReasons {
  static const List<String> all = [
    'Produk palsu / tidak sesuai deskripsi',
    'Konten tidak pantas',
    'Harga tidak wajar',
    'Pelanggaran hak cipta',
    'Lainnya',
  ];
}
