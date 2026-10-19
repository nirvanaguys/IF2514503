import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'widgets/widgets.dart';

class DiagnosisScreen extends StatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final ImagePicker _picker = ImagePicker();
  String _selectedCategory = 'Semua';
  File? _selectedImage;
  bool _isPickingImage = false;

  static const List<String> _categories = [
    'Semua',
    'Tanaman Hias',
    'Tanaman Pekarangan',
    'Belum Tahu',
  ];

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );

      if (!mounted) return;
      if (pickedImage != null) {
        setState(() => _selectedImage = File(pickedImage.path));
        _showMessage('Foto berhasil dipilih. Preview tersedia di bawah.');
      }
      // Jika pengguna membatalkan pemilihan, layar tetap seperti semula.
    } on PlatformException catch (error) {
      if (!mounted) return;
      _showMessage('Tidak dapat membuka foto: ${error.message ?? error.code}');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Terjadi kesalahan saat memilih foto. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DiagnosisHeader(
              onNotificationTap: () => _showMessage('Notifikasi belum tersedia.'),
              onProfileTap: () => _showMessage('Profil belum tersedia.'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DiagnosisStepper(
                      currentStep: _selectedImage != null ? 2 : 1,
                    ),
                    const SizedBox(height: 16),
                    DiagnosisQuotaBanner(
                      onUpgradeTap: () => _showMessage('Fitur Upgrade belum tersedia.'),
                    ),
                    const SizedBox(height: 20),
                    CategoryChipsSelector(
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImage != null) ...[
                      ImagePreviewCard(
                        image: _selectedImage!,
                        selectedCategory: _selectedCategory,
                        onRemove: () {
                          setState(() => _selectedImage = null);
                        },
                        onAnalyze: () {
                          _showMessage(
                            'Preview berhasil. Fitur analisis belum dibuat, '
                            'jadi foto belum didiagnosis.',
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    ImagePickerSection(
                      isPickingImage: _isPickingImage,
                      onCameraTap: () => _pickImage(ImageSource.camera),
                      onGalleryTap: () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(height: 16),
                    const PhotographyTipsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
