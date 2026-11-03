import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../admin/models/admin_models.dart';
import '../../admin/services/admin_service.dart';
import '../models/product_model.dart';
import '../services/wishlist_service.dart';
import '../widgets/product_reviews_section.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  final bool initialIsWishlisted;
  final ValueChanged<ProductModel>? onAddToCart;
  final ValueChanged<bool>? onWishlistChanged;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.initialIsWishlisted = false,
    this.onAddToCart,
    this.onWishlistChanged,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isWishlisted;
  final _wishlistService = WishlistService();
  final _authService = AuthService();
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.initialIsWishlisted;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleWishlist() async {
    final nextState = !_isWishlisted;
    setState(() => _isWishlisted = nextState);

    widget.onWishlistChanged?.call(nextState);

    final user = _authService.currentUser;
    if (user != null) {
      if (nextState) {
        await _wishlistService.addToWishlist(user.id, widget.product.id);
        _showMessage('Produk ditambahkan ke wishlist.');
      } else {
        await _wishlistService.removeFromWishlist(user.id, widget.product.id);
        _showMessage('Produk dihapus dari wishlist.');
      }
    } else {
      _showMessage(
        nextState
            ? 'Disimpan sementara. Masuk akun untuk menyimpan permanen.'
            : 'Dihapus dari wishlist.',
      );
    }
  }

  void _handleAddToCart() {
    if (widget.product.stock <= 0) {
      _showMessage('Maaf, stok produk ini sedang habis.');
      return;
    }

    widget.onAddToCart?.call(widget.product);
    _showMessage(
      '${quantityText.isNotEmpty ? "$quantityText " : ""}"${widget.product.name}" berhasil ditambahkan ke keranjang!',
    );
  }

  Future<void> _showReportDialog() async {
    final user = _authService.currentUser;
    if (user == null) {
      _showMessage('Silakan masuk ke akun Anda untuk melaporkan produk.');
      return;
    }

    String? selectedReason;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Laporkan Produk'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih alasan laporan:',
                    style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
                  ),
                  const SizedBox(height: 10),
                  ...ReportReasons.all.map((reason) {
                    return RadioListTile<String>(
                      title: Text(reason, style: const TextStyle(fontSize: 13)),
                      value: reason,
                      groupValue: selectedReason,
                      activeColor: AppTheme.forest,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDialogState(() => selectedReason = val);
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: selectedReason != null
                      ? () => Navigator.of(ctx).pop(true)
                      : null,
                  child: const Text('Kirim Laporan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || selectedReason == null || !mounted) return;

    try {
      final adminService = AdminService();
      await adminService.submitReport(
        reporterId: user.id,
        productId: widget.product.id,
        reason: selectedReason!,
      );
      if (mounted) {
        _showMessage('Laporan berhasil dikirim. Terima kasih!');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Gagal mengirim laporan: $e');
      }
    }
  }

  String get quantityText => _quantity > 1 ? '$_quantity x' : '';

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.stock <= 0;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101F16),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppTheme.forest,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.flag_outlined,
              color: AppTheme.mutedText,
              size: 22,
            ),
            tooltip: 'Laporkan Produk',
            onPressed: _showReportDialog,
          ),
          IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? const Color(0xFFC62828) : AppTheme.forest,
            ),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Gambar Produk
                  Container(
                    width: double.infinity,
                    height: 280,
                    color: AppTheme.paleGreen,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: AppTheme.mutedText,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.eco,
                                    size: 72,
                                    color: AppTheme.forest,
                                  ),
                                ),
                        ),
                        // Badge Status Stok di atas gambar
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? const Color(0xFFC62828)
                                  : (product.isLimitedStock
                                        ? const Color(0xFF9A6700)
                                        : AppTheme.forest),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isOutOfStock
                                  ? 'Stok Habis'
                                  : (product.isLimitedStock
                                        ? 'Sisa ${product.stock} Unit'
                                        : 'Stok Tersedia (${product.stock})'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Info Utama Produk
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.softGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.category,
                                style: const TextStyle(
                                  color: AppTheme.forest,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 18,
                                  color: Color(0xFFFFA000),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '(${product.reviewCount} ulasan)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Nama Produk
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101F16),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Harga
                        Text(
                          product.formattedPrice,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.forest,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. Info Toko Penjual
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.softGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: AppTheme.forest,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    product.storeName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF101F16),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppTheme.forest,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Penjual Resmi DaunKu',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 4. Deskripsi Produk
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101F16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          product.description.isNotEmpty ? product.description : 'Produk pertanian bermutu tinggi untuk menunjang kesehatan dan keindahan tanaman Anda di rumah.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 5. Ulasan Pembeli
                  ProductReviewsSection(productId: product.id),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Bar Aksi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Pengatur Jumlah (Quantity)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDCE4DD)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: _quantity < product.stock
                              ? () => setState(() => _quantity++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Tombol Tambah ke Keranjang
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isOutOfStock ? null : _handleAddToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      label: Text(
                        isOutOfStock ? 'Stok Habis' : '+ Keranjang',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
