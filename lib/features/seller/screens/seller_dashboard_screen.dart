import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../marketplace/models/product_model.dart';
import '../models/seller_profile_model.dart';
import '../services/seller_service.dart';
import 'add_edit_product_screen.dart';

class SellerDashboardScreen extends StatefulWidget {
  final SellerProfileModel sellerProfile;

  const SellerDashboardScreen({super.key, required this.sellerProfile});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final _sellerService = SellerService();
  List<ProductModel> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final list = await _sellerService.fetchSellerProducts(widget.sellerProfile.userId);
    if (mounted) {
      setState(() {
        _products = list;
        _isLoading = false;
      });
    }
  }

  void _openAddEditProduct([ProductModel? product]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(
          sellerId: widget.sellerProfile.userId,
          storeName: widget.sellerProfile.storeName,
          productToEdit: product,
        ),
      ),
    ).then((_) => _loadProducts());
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk?'),
        content: Text('Produk "${product.name}" akan dihapus dari katalog toko Anda.'),
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
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sellerService.deleteProduct(product.id, widget.sellerProfile.userId);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalStock = _products.fold<int>(0, (sum, p) => sum + p.stock);

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Pusat Penjual',
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
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppTheme.forest),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.forest),
            tooltip: 'Tambah Produk',
            onPressed: () => _openAddEditProduct(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Store Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.softGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.storefront, color: AppTheme.forest, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    widget.sellerProfile.storeName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, size: 16, color: AppTheme.forest),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.sellerProfile.description ?? 'Toko Pertanian Resmi DaunKu',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Statistik Toko
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE8EEE9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Produk', style: TextStyle(fontSize: 12, color: AppTheme.mutedText)),
                              const SizedBox(height: 4),
                              Text(
                                '${_products.length}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.forest),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE8EEE9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Stok', style: TextStyle(fontSize: 12, color: AppTheme.mutedText)),
                              const SizedBox(height: 4),
                              Text(
                                '$totalStock unit',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF526523)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Header Bagian Produk
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Katalog Produk Toko',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      TextButton.icon(
                        onPressed: () => _openAddEditProduct(),
                        icon: const Icon(Icons.add, size: 18, color: AppTheme.forest),
                        label: const Text('Tambah Produk', style: TextStyle(color: AppTheme.forest, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_products.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 56, color: AppTheme.mutedText),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum Ada Produk Ditambahkan',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Mulai terbitkan produk pupuk, obat, atau pot Anda agar dapat dibeli pengguna.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppTheme.mutedText, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _openAddEditProduct(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.forest,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Terbitkan Produk Pertama'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._products.map((product) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE8EEE9)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 64,
                                height: 64,
                                color: AppTheme.paleGreen,
                                child: product.imageUrl.isNotEmpty
                                    ? Image.network(
                                        product.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(Icons.eco, color: AppTheme.forest),
                                      )
                                    : const Icon(Icons.eco, color: AppTheme.forest),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.formattedPrice,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: AppTheme.forest,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Stok: ${product.stock} unit • ${product.category}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppTheme.forest, size: 20),
                              onPressed: () => _openAddEditProduct(product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFC62828), size: 20),
                              onPressed: () => _deleteProduct(product),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}

