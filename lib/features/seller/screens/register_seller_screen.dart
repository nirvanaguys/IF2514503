import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../services/seller_service.dart';
import 'seller_dashboard_screen.dart';

class RegisterSellerScreen extends StatefulWidget {
  const RegisterSellerScreen({super.key});

  @override
  State<RegisterSellerScreen> createState() => _RegisterSellerScreenState();
}

class _RegisterSellerScreenState extends State<RegisterSellerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellerService = SellerService();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _authService.currentUser;
    if (user == null) {
      setState(
        () => _errorMessage = 'Silakan masuk ke akun Anda terlebih dahulu.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sellerProfile = await _sellerService.registerSeller(
        userId: user.id,
        storeName: _storeNameController.text,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selamat! Toko Anda berhasil diaktifkan.'),
          backgroundColor: AppTheme.forest,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              SellerDashboardScreen(sellerProfile: sellerProfile),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Daftar Sebagai Penjual',
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Banner Hero Penjual
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.softGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.forest.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.forest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.storefront,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Buka Toko di DaunKu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF101F16),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Jangkau ribuan pecinta tanaman yang membutuhkan pupuk, obat, dan pot.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.forest,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAD6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF93000A),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                AuthTextField(
                  controller: _storeNameController,
                  label: 'Nama Toko Pertanian',
                  hintText: 'Contoh: Kebun Berkah Flora',
                  prefixIcon: Icons.store_mall_directory_outlined,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama toko tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi Toko (Opsional)',
                  hintText: 'Jelaskan produk utama yang Anda jual...',
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forest,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Aktifkan Toko Sekarang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
