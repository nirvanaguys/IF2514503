import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../cart/services/cart_service.dart';
import '../../orders/screens/orders_screen.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../services/checkout_service.dart';
import 'address_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cartService = CartService();
  final _addressService = AddressService();
  final _checkoutService = CheckoutService();
  final _authService = AuthService();

  AddressModel? _selectedAddress;
  bool _isLoading = false;
  bool _isCreatingOrder = false;
  String _selectedPaymentMethod = 'BCA Virtual Account';
  static const int _shippingCost = 15000;

  @override
  void initState() {
    super.initState();
    _loadInitialAddress();
  }

  Future<void> _loadInitialAddress() async {
    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    final addresses = await _addressService.fetchAddresses(user?.id ?? '');
    if (mounted) {
      setState(() {
        if (addresses.isNotEmpty) {
          _selectedAddress = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
        }
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _changeAddress() async {
    final result = await Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(
        builder: (context) => AddressListScreen(selectedAddress: _selectedAddress),
      ),
    );
    if (result != null && mounted) {
      setState(() => _selectedAddress = result);
    }
  }

  Future<void> _handlePlaceOrder() async {
    if (_isCreatingOrder) return;

    if (_selectedAddress == null) {
      _showMessage('Silakan pilih alamat pengiriman terlebih dahulu.');
      return;
    }

    if (_cartService.items.isEmpty) {
      _showMessage('Keranjang belanja kosong.');
      return;
    }

    setState(() => _isCreatingOrder = true);

    try {
      final user = _authService.currentUser;
      final order = await _checkoutService.createOrder(
        userId: user?.id ?? 'guest_user',
        address: _selectedAddress!,
        items: _cartService.items,
        shippingCost: _shippingCost,
        paymentProvider: _selectedPaymentMethod,
      );

      if (!mounted) return;

      // Tampilkan dialog sukses pemesanan
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.softGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppTheme.forest, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pesanan Berhasil Dibuat!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'ID Pesanan: ${order.id}\nTotal: ${order.formattedTotal}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppTheme.mutedText),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.paleGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      _selectedPaymentMethod,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.paymentReference ?? 'VA-8829-123456',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.forest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forest,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const OrdersScreen()),
                );
              },
              child: const Text('Lihat Pesanan Saya'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal membuat pesanan: $e');
    } finally {
      if (mounted) setState(() => _isCreatingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;
    final subtotal = _cartService.totalAmount;
    final total = subtotal + _shippingCost;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Checkout Pesanan',
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Alamat Pengiriman Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.location_on, color: AppTheme.forest, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Alamat Pengiriman',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _changeAddress,
                              child: const Text(
                                'Ubah',
                                style: TextStyle(color: AppTheme.forest, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        if (_selectedAddress != null) ...[
                          Text(
                            '${_selectedAddress!.recipientName} (${_selectedAddress!.phone})',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedAddress!.fullAddressText,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.3),
                          ),
                        ] else
                          OutlinedButton.icon(
                            onPressed: _changeAddress,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Pilih Alamat Pengiriman'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Ringkasan Produk
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Produk',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ...items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    color: AppTheme.paleGreen,
                                    child: item.product.imageUrl.isNotEmpty
                                        ? Image.network(item.product.imageUrl, fit: BoxFit.cover)
                                        : const Icon(Icons.eco, color: AppTheme.forest, size: 22),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      Text(
                                        '${item.quantity} x ${item.product.formattedPrice}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.formattedSubtotal,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Metode Pembayaran Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Metode Pembayaran',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentOption(
                          'BCA Virtual Account',
                          'BCA Virtual Account (Otomatis)',
                          Icons.account_balance,
                        ),
                        const SizedBox(height: 8),
                        _buildPaymentOption(
                          'QRIS / GoPay / OVO',
                          'QRIS (Scan Bebas Biaya)',
                          Icons.qr_code_2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Rincian Pembayaran
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EEE9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rincian Biaya',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal Produk', style: TextStyle(color: AppTheme.mutedText)),
                            Text(_cartService.formattedTotalAmount, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ongkos Kirim (Standar)', style: TextStyle(color: AppTheme.mutedText)),
                            Text('Rp 15.000', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Tagihan',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            Text(
                              'Rp ${_formatRupiah(total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: AppTheme.forest,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
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
          child: ElevatedButton(
            onPressed: _isCreatingOrder ? null : _handlePlaceOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forest,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isCreatingOrder
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Bayar Sekarang (Rp ${_formatRupiah(total)})',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.softGreen : AppTheme.pageBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.forest : const Color(0xFFE8EEE9),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.forest : AppTheme.mutedText, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                  color: const Color(0xFF101F16),
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.forest : AppTheme.mutedText,
              size: 20,
            ),
          ],
        ),
      ),
    );
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
}
