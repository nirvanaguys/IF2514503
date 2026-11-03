class OrderItemModel {
  final String id;
  final String orderId;
  final String? productId;
  final String sellerId;
  final String productName;
  final int unitPrice;
  final int quantity;
  final int lineTotal;
  final String? imageUrl;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    this.productId,
    required this.sellerId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.imageUrl,
  });

  String get formattedPrice => 'Rp ${_formatRupiah(unitPrice)}';
  String get formattedLineTotal => 'Rp ${_formatRupiah(lineTotal)}';

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String?,
      sellerId: json['seller_id'] as String? ?? '',
      productName: json['product_name_snapshot'] as String? ?? 'Produk Tanaman',
      unitPrice: json['unit_price'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      lineTotal: json['line_total'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'seller_id': sellerId,
      'product_name_snapshot': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'line_total': lineTotal,
    };
  }
}

class OrderModel {
  final String id;
  final String buyerId;
  final String status;
  final int subtotal;
  final int shippingCost;
  final int total;
  final Map<String, dynamic> shippingAddressSnapshot;
  final String? paymentProvider;
  final String? paymentReference;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.status,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.shippingAddressSnapshot,
    this.paymentProvider,
    this.paymentReference,
    required this.createdAt,
    this.items = const [],
  });

  String get formattedSubtotal => 'Rp ${_formatRupiah(subtotal)}';
  String get formattedShippingCost => 'Rp ${_formatRupiah(shippingCost)}';
  String get formattedTotal => 'Rp ${_formatRupiah(total)}';

  String get statusBadgeText {
    switch (status) {
      case 'pending_payment':
        return 'Menunggu Pembayaran';
      case 'paid':
        return 'Sudah Dibayar';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((it) => OrderItemModel.fromJson(it as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id'] as String,
      buyerId: json['buyer_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending_payment',
      subtotal: json['subtotal'] as int? ?? 0,
      shippingCost: json['shipping_cost'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      shippingAddressSnapshot:
          json['shipping_address_snapshot'] as Map<String, dynamic>? ?? {},
      paymentProvider: json['payment_provider'] as String?,
      paymentReference: json['payment_reference'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'status': status,
      'subtotal': subtotal,
      'shipping_cost': shippingCost,
      'total': total,
      'shipping_address_snapshot': shippingAddressSnapshot,
      if (paymentProvider != null) 'payment_provider': paymentProvider,
      if (paymentReference != null) 'payment_reference': paymentReference,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

String _formatRupiah(int amount) {
  final str = amount.toString();
  final buffer = StringBuffer();
  final len = str.length;
  for (int i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(str[i]);
  }
  return buffer.toString();
}

