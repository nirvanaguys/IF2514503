import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';

class AddEditAddressScreen extends StatefulWidget {
  final String userId;
  final AddressModel? addressToEdit;

  const AddEditAddressScreen({
    super.key,
    required this.userId,
    this.addressToEdit,
  });

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressLineController;
  late final TextEditingController _cityController;
  late final TextEditingController _provinceController;
  late final TextEditingController _postalCodeController;
  late bool _isDefault;
  bool _isLoading = false;

  final _addressService = AddressService();

  @override
  void initState() {
    super.initState();
    final a = widget.addressToEdit;
    _nameController = TextEditingController(text: a?.recipientName ?? '');
    _phoneController = TextEditingController(text: a?.phone ?? '');
    _addressLineController = TextEditingController(text: a?.addressLine ?? '');
    _cityController = TextEditingController(text: a?.city ?? '');
    _provinceController = TextEditingController(text: a?.province ?? '');
    _postalCodeController = TextEditingController(text: a?.postalCode ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newAddress = AddressModel(
        id: widget.addressToEdit?.id ??
            'addr_${DateTime.now().millisecondsSinceEpoch}',
        userId: widget.userId,
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        city: _cityController.text.trim(),
        province: _provinceController.text.trim(),
        postalCode: _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        isDefault: _isDefault,
      );

      final saved = await _addressService.saveAddress(newAddress);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat pengiriman berhasil disimpan!'),
          backgroundColor: AppTheme.forest,
        ),
      );
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan alamat: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.addressToEdit != null;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Ubah Alamat' : 'Tambah Alamat Baru',
          style: const TextStyle(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _nameController,
                  label: 'Nama Penerima',
                  hintText: 'Contoh: Wisnu Wardhana',
                  prefixIcon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nama penerima wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  hintText: '08xxxxxxxxxx',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Nomor telepon wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _addressLineController,
                  label: 'Alamat Lengkap',
                  hintText: 'Jalan, nomor rumah, RT/RW, kelurahan/desa',
                  prefixIcon: Icons.home_outlined,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Alamat lengkap wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _cityController,
                        label: 'Kota / Kabupaten',
                        hintText: 'Jakarta Selatan',
                        prefixIcon: Icons.location_city_outlined,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Kota wajib diisi' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthTextField(
                        controller: _provinceController,
                        label: 'Provinsi',
                        hintText: 'DKI Jakarta',
                        prefixIcon: Icons.map_outlined,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Provinsi wajib diisi' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _postalCodeController,
                  label: 'Kode Pos (Opsional)',
                  hintText: '12410',
                  prefixIcon: Icons.markunread_mailbox_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // Switch Jadikan Alamat Utama
                SwitchListTile(
                  title: const Text(
                    'Jadikan Alamat Utama',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Alamat ini akan otomatis dipilih saat checkout',
                    style: TextStyle(fontSize: 12, color: AppTheme.mutedText),
                  ),
                  value: _isDefault,
                  activeThumbColor: AppTheme.forest,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _isDefault = val),
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
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
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Alamat',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
