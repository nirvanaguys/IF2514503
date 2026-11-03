import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/services/auth_service.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  final AddressModel? selectedAddress;

  const AddressListScreen({super.key, this.selectedAddress});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final _addressService = AddressService();
  final _authService = AuthService();
  List<AddressModel> _addresses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    final user = _authService.currentUser;
    final list = await _addressService.fetchAddresses(user?.id ?? '');
    if (mounted) {
      setState(() {
        _addresses = list;
        _isLoading = false;
      });
    }
  }

  void _openAddEditAddress([AddressModel? address]) {
    final user = _authService.currentUser;
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddEditAddressScreen(
              userId: user?.id ?? '',
              addressToEdit: address,
            ),
          ),
        )
        .then((_) => _loadAddresses());
  }

  Future<void> _confirmDeleteAddress(AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Alamat?'),
        content: Text(
          'Alamat "${address.recipientName}" di ${address.city} akan dihapus.',
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
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final user = _authService.currentUser;
      await _addressService.deleteAddress(user?.id ?? '', address.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat berhasil dihapus.')),
        );
        _loadAddresses();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Pilih Alamat Pengiriman',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_off_outlined,
                      size: 56,
                      color: AppTheme.mutedText,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum Ada Alamat Tersimpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _openAddEditAddress(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Alamat Baru'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _addresses[index];
                final isSelected = widget.selectedAddress?.id == item.id;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.forest
                          : const Color(0xFFE8EEE9),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(item),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.recipientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (item.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.softGreen,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Utama',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.forest,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: AppTheme.mutedText,
                                ),
                                onPressed: () => _openAddEditAddress(item),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: Color(0xFFC62828),
                                ),
                                onPressed: () => _confirmDeleteAddress(item),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.phone,
                            style: const TextStyle(
                              color: AppTheme.mutedText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.fullAddressText,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF333333),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SafeArea(
          child: OutlinedButton.icon(
            onPressed: () => _openAddEditAddress(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: AppTheme.forest,
              side: const BorderSide(color: AppTheme.forest),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'Tambah Alamat Baru',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
