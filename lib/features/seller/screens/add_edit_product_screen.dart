import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../marketplace/data/marketplace_demo_data.dart';
import '../../marketplace/services/marketplace_service.dart';
import '../services/seller_service.dart';

class AddEditProductScreen extends StatefulWidget {
  final String sellerId;
  final String storeName;
  final ProductModel? productToEdit;

  const AddEditProductScreen({
    super.key,
    required this.sellerId,
    required this.storeName,
    this.productToEdit,
  });

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _imageUrlController;
  late String _selectedCategory;
  late bool _isPublished;

  final _sellerService = SellerService();
  final _marketplaceService = MarketplaceService();
  final _picker = ImagePicker();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  List<String> _dbCategories = [];

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _nameController = TextEditingController(text: p?.name ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null ? p.price.toString() : '',
    );
    _stockController = TextEditingController(
      text: p != null ? p.stock.toString() : '10',
    );
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _selectedCategory =
        p != null && MarketplaceDemoData.categories.contains(p.category)
        ? p.category
        : (MarketplaceDemoData.categories.length > 1
              ? MarketplaceDemoData.categories[1]
              : 'Pupuk Organik');
    _isPublished = p?.isPublished ?? true;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _marketplaceService.fetchCategories();
    if (mounted) {
      setState(() {
        _dbCategories = categories.where((c) => c != 'Semua').toList();
        // Pastikan kategori terpilih ada dalam daftar
        if (!_dbCategories.contains(_selectedCategory) &&
            _dbCategories.isNotEmpty) {
          _selectedCategory = _dbCategories.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _isUploadingImage = true;
        });

        final bytes = await picked.readAsBytes();
        final publicUrl = await _sellerService.uploadImageBytes(
          widget.sellerId,
          bytes,
          picked.name,
        );

        if (mounted) {
          if (publicUrl != null) {
            _imageUrlController.text = publicUrl;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto produk berhasil diunggah ke Storage!'),
                backgroundColor: AppTheme.forest,
              ),
            );
          } else {
            // Fallback path
            _imageUrlController.text = picked.path;
          }
          setState(() => _isUploadingImage = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal memilih foto: $e')));
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    setState(() => _isLoading = true);

    try {
      if (widget.productToEdit != null) {
        final updated = widget.productToEdit!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          stock: stock,
          category: _selectedCategory,
          imageUrl: _imageUrlController.text.trim(),
          isPublished: _isPublished,
        );
        await _sellerService.updateProduct(updated);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diperbarui!'),
            backgroundColor: AppTheme.forest,
          ),
        );
        Navigator.of(context).pop(updated);
      } else {
        final created = await _sellerService.createProduct(
          sellerId: widget.sellerId,
          storeName: widget.storeName,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          price: price,
          stock: stock,
          imageUrl: _imageUrlController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk berhasil diterbitkan ke katalog!'),
            backgroundColor: AppTheme.forest,
          ),
        );
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan produk: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productToEdit != null;
    final availableCategories = _dbCategories.isNotEmpty
        ? _dbCategories
        : MarketplaceDemoData.categories.where((c) => c != 'Semua').toList();

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Ubah Produk' : 'Tambah Produk Baru',
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
                // Preview & Picker Gambar
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8EEE9)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_imageUrlController.text.isNotEmpty &&
                          _imageUrlController.text.startsWith('http'))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _imageUrlController.text,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.image,
                              size: 48,
                              color: AppTheme.forest,
                            ),
                          ),
                        )
                      else
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: AppTheme.forest,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isUploadingImage
                                  ? 'Mengunggah ke Storage...'
                                  : 'Pilih Foto Produk',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Row(
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              icon: const Icon(
                                Icons.photo_library,
                                color: AppTheme.forest,
                                size: 20,
                              ),
                              tooltip: 'Buka Galeri',
                              onPressed: () => _pickImage(ImageSource.gallery),
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              icon: const Icon(
                                Icons.camera_alt,
                                color: AppTheme.forest,
                                size: 20,
                              ),
                              tooltip: 'Ambil Foto',
                              onPressed: () => _pickImage(ImageSource.camera),
                            ),
                          ],
                        ),
                      ),
                      if (_isUploadingImage)
                        Container(
                          color: Colors.black38,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _nameController,
                  label: 'Nama Produk',
                  hintText: 'Contoh: Pupuk Cair Organik 500ml',
                  prefixIcon: Icons.shopping_bag_outlined,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Nama produk wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // Dropdown Kategori
                const Text(
                  'Kategori Produk',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101F16),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCE4DD)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      items: availableCategories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: AuthTextField(
                        controller: _priceController,
                        label: 'Harga (Rupiah)',
                        hintText: '35000',
                        prefixIcon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'Harus angka bulat';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthTextField(
                        controller: _stockController,
                        label: 'Jumlah Stok',
                        hintText: '10',
                        prefixIcon: Icons.inventory_2_outlined,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Stok wajib diisi';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'Harus angka';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _descriptionController,
                  label: 'Deskripsi Produk',
                  hintText:
                      'Jelaskan kegunaan, takaran pemakaian, dan manfaat...',
                  prefixIcon: Icons.notes_outlined,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Deskripsi produk wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                AuthTextField(
                  controller: _imageUrlController,
                  label: 'Tautan Gambar (Opsional)',
                  hintText: 'https://...',
                  prefixIcon: Icons.link_outlined,
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: const Text(
                    'Publikasikan di Katalog',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Produk dapat dilihat dan dibeli oleh pelanggan',
                    style: TextStyle(fontSize: 12, color: AppTheme.mutedText),
                  ),
                  value: _isPublished,
                  activeThumbColor: AppTheme.forest,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => _isPublished = val),
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
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing ? 'Simpan Perubahan' : 'Terbitkan Produk',
                          style: const TextStyle(
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
