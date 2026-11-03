import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile initialProfile;
  final ValueChanged<UserProfile>? onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.initialProfile,
    this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  final _profileService = ProfileService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.displayName);
    _phoneController = TextEditingController(text: widget.initialProfile.phone ?? '');
    _emailController = TextEditingController(text: widget.initialProfile.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updated = await _profileService.updateProfile(
        userId: widget.initialProfile.id,
        displayName: _nameController.text,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        email: widget.initialProfile.email,
        avatarPath: widget.initialProfile.avatarPath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: AppTheme.forest,
        ),
      );

      if (widget.onProfileUpdated != null) {
        widget.onProfileUpdated!(updated);
      }

      Navigator.of(context).pop(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Color(0xFF101F16),
            fontSize: 18,
            fontWeight: FontWeight.w700,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar Preview
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppTheme.softGreen,
                        child: Text(
                          widget.initialProfile.displayName.isNotEmpty
                              ? widget.initialProfile.displayName[0].toUpperCase()
                              : 'D',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forest,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.forest,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Error Banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDAD6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC62828).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFF93000A),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Input Nama
                AuthTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hintText: 'Nama tampilan Anda',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Email (Readonly)
                AuthTextField(
                  controller: _emailController,
                  label: 'Email (Terverifikasi)',
                  hintText: 'Email Anda',
                  prefixIcon: Icons.mail_outline,
                  enabled: false,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Email terikat dengan autentikasi akun dan tidak dapat diubah di sini.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.mutedText,
                  ),
                ),
                const SizedBox(height: 16),

                // Input Telepon
                AuthTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon (Opsional)',
                  hintText: '08123456789',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 32),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forest,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
