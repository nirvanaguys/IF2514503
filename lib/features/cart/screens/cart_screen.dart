import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../checkout/screens/checkout_screen.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    await _cartService.fetchCart(user?.id);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _proceedToCheckout() {
    if (_cartService.items.isEmpty) {
      _showMessage('Keranjang belanja Anda masih kosong.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CheckoutScreen(),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Keranjang Belanja',
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
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFC62828)),
              tooltip: 'Kosongkan Keranjang',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Kosongkan Keranjang?'),
                    content: const Text('Seluruh produk di keranjang akan dihapus.'),
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
                        child: const Text('Hapus Semua'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _cartService.clearCart(user?.id);
                  setState(() {});
                  _showMessage('Keranjang belanja dikosongkan.');
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: AppTheme.softGreen,
                            borderRadius: BorderRadius.circular(44),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 44,
                            color: AppTheme.forest,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Keranjangmu Masih Kosong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF101F16),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Temukan pupuk, obat tanaman, dan perlengkapan berkebun berkualitas di marketplace kami.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mutedText,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.forest,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Belanja Sekarang'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item.product;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8EEE9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Foto Produk
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: AppTheme.paleGreen,
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.eco,
                                        color: AppTheme.forest,
                                      ),
                                    )
                                  : const Icon(Icons.eco, color: AppTheme.forest),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Deskripsi & Kontrol
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.storeName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.mutedText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await _cartService.removeFromCart(user?.id, product.id);
                                        setState(() {});
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: AppTheme.mutedText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF101F16),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Harga & Kuantitas
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.formattedPrice,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.forest,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFFDCE4DD)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              await _cartService.updateQuantity(
                                                user?.id,
                                                product.id,
                                                item.quantity - 1,
                                              );
                                              setState(() {});
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.remove, size: 16),
                                            ),
                                          ),
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              if (item.quantity < product.stock) {
                                                await _cartService.updateQuantity(
                                                  user?.id,
                                                  product.id,
                                                  item.quantity + 1,
                                                );
                                                setState(() {});
                                              } else {
                                                _showMessage('Stok produk telah mencapai batas.');
                                              }
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              child: Icon(Icons.add, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: items.isNotEmpty
          ? Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.mutedText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _cartService.formattedTotalAmount,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.forest,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _proceedToCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forest,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Lanjut Checkout',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
