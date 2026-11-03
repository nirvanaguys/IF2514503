import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/theme/app_theme.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../orders/screens/orders_screen.dart';
import '../../orders/services/order_service.dart';
import '../../seller/screens/register_seller_screen.dart';
import '../../seller/screens/seller_dashboard_screen.dart';
import '../../seller/services/seller_service.dart';
import '../data/profile_demo_data.dart';
import '../widgets/widgets.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _orderService = OrderService();
  UserProfile? _currentProfile;
  bool _isLoading = false;
  int _activeOrderCount = 0;
  StreamSubscription<supa.AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _authSubscription = _authService.authStateChanges.listen((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!_authService.isAuthenticated) {
      if (mounted) {
        setState(() {
          _currentProfile = null;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final profile = await _authService.fetchCurrentProfile();
    // Ambil jumlah pesanan aktif dari data nyata
    final user = _authService.currentUser;
    int orderCount = 0;
    if (user != null) {
      orderCount = await _orderService.countActiveOrders(user.id);
    }
    if (mounted) {
      setState(() {
        _currentProfile = profile;
        _activeOrderCount = orderCount;
        _isLoading = false;
      });
    }
  }

  Future<void> _openSellerCenter() async {
    if (!_authService.isAuthenticated) {
      _navigateToLogin(
        reason:
            'Silakan masuk akun terlebih dahulu untuk membuka Pusat Penjual.',
      );
      return;
    }

    final user = _authService.currentUser;
    final sellerService = SellerService();
    final profile = await sellerService.fetchSellerProfile(user?.id ?? '');

    if (!mounted) return;

    if (profile != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SellerDashboardScreen(sellerProfile: profile),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const RegisterSellerScreen()),
      );
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openEditProfile() {
    if (!_authService.isAuthenticated) {
      _navigateToLogin(
        reason: 'Silakan masuk terlebih dahulu untuk mengubah profil Anda.',
      );
      return;
    }

    final profile =
        _currentProfile ??
        UserProfile(
          id: _authService.currentUser!.id,
          displayName: ProfileDemoData.userName,
          email: _authService.currentUser!.email ?? ProfileDemoData.email,
        );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialProfile: profile,
          onProfileUpdated: (updated) {
            setState(() {
              _currentProfile = updated;
            });
          },
        ),
      ),
    );
  }

  void _navigateToLogin({String? reason}) {
    if (reason != null) {
      _showMessage(context, reason);
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          onLoginSuccess: () {
            Navigator.of(context).pop();
            _loadProfile();
          },
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    if (!_authService.isAuthenticated) {
      _showMessage(context, 'Anda saat ini belum login.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Anda harus masuk kembali untuk melihat riwayat diagnosis dan pesanan Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        _showMessage(context, 'Berhasil keluar dari akun.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _authService.isAuthenticated;
    final displayName =
        _currentProfile?.displayName ?? ProfileDemoData.userName;
    final displayEmail =
        _currentProfile?.email ??
        (_authService.currentUser?.email ?? ProfileDemoData.email);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            ProfileHeader(
              onNotificationTap: () =>
                  _showMessage(context, 'Notifikasi belum tersedia.'),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Login Prompt Banner jika belum login
                    if (!isLoggedIn) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.softGreen,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.forest.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_circle,
                              color: AppTheme.forest,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Masuk ke DaunKu',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Color(0xFF101F16),
                                    ),
                                  ),
                                  Text(
                                    'Simpan diagnosis & kelola belanja tanamanmu.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.forest,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _navigateToLogin(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.forest,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // 1. Profile User Card
                    ProfileUserCard(
                      userName: _isLoading ? 'Memuat profil...' : displayName,
                      email: _isLoading ? '...' : displayEmail,
                      planBadge: ProfileDemoData.planBadge,
                      onEditTap: _openEditProfile,
                    ),
                    const SizedBox(height: 12),

                    // 2. Bento Key Stats
                    ProfileStatsBento(
                      completedDiagnosis: ProfileDemoData.completedDiagnosis,
                      activeOrders: _activeOrderCount,
                      remainingQuota: ProfileDemoData.remainingQuota,
                      totalQuota: ProfileDemoData.totalQuota,
                      onDiagnosisStatsTap: () => _showMessage(
                        context,
                        'Riwayat diagnosis lengkap akan hadir di tahap riwayat.',
                      ),
                      onOrdersStatsTap: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const OrdersScreen(),
                              ),
                            )
                            .then((_) => _loadProfile());
                      },
                      onQuotaStatsTap: () => _showMessage(
                        context,
                        'Sisa kuota gratis Anda: ${ProfileDemoData.remainingQuota}/${ProfileDemoData.totalQuota} kali.',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Upgrade Premium Banner
                    ProfileUpgradeBanner(
                      onUpgradeTap: () => _showMessage(
                        context,
                        'Paket langganan Premium belum dibuka pada versi demo.',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Menu Grup 1: Aktivitas & Riwayat
                    ProfileMenuGroup(
                      groupTitle: 'Aktivitas & Riwayat',
                      items: [
                        ProfileMenuItem(
                          icon: Icons.document_scanner_outlined,
                          title: 'Riwayat Diagnosis',
                          subtitle: 'Lihat riwayat scan tanaman & hasil AI',
                          badgeText:
                              '${ProfileDemoData.completedDiagnosis} Scan',
                          badgeColor: AppTheme.softGreen,
                          badgeTextColor: AppTheme.forest,
                          onTap: () => _showMessage(
                            context,
                            'Riwayat scan tanaman akan hadir di tahap riwayat.',
                          ),
                        ),
                        ProfileMenuItem(
                          icon: Icons.receipt_long_outlined,
                          title: 'Pesanan Saya',
                          subtitle: 'Status pengiriman obat & pupuk',
                          badgeText: 'Lihat',
                          badgeColor: const Color(0xFFD5EC9A),
                          badgeTextColor: const Color(0xFF3B4D0C),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const OrdersScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 5. Menu Grup 2: Layanan & Komunitas
                    ProfileMenuGroup(
                      groupTitle: 'Layanan & Komunitas',
                      items: [
                        ProfileMenuItem(
                          icon: Icons.storefront_outlined,
                          title: 'Pusat Penjual / Jadi Penjual',
                          subtitle: 'Jual produk perawatan tanamanmu',
                          onTap: _openSellerCenter,
                        ),
                        ProfileMenuItem(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notifikasi & Pengingat Rawat',
                          subtitle: 'Jadwal siram, pupuk & kabar promo',
                          onTap: () => _showMessage(
                            context,
                            'Pengingat jadwal rawat belum aktif di versi demo.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 6. Menu Grup 3: Pusat Akun
                    ProfileMenuGroup(
                      groupTitle: 'Pusat Akun',
                      items: [
                        ProfileMenuItem(
                          icon: Icons.help_outline,
                          title: 'Bantuan & FAQ',
                          iconBackgroundColor: const Color(0xFFEFF3EE),
                          iconColor: const Color(0xFF101F16),
                          onTap: () => _showMessage(
                            context,
                            'Pusat bantuan DaunKu. Hubungi support@daunku.local',
                          ),
                        ),
                        ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Pengaturan Akun',
                          iconBackgroundColor: const Color(0xFFEFF3EE),
                          iconColor: const Color(0xFF101F16),
                          onTap: () => _showMessage(
                            context,
                            'Pengaturan akun akan hadir pada pembaruan berikutnya.',
                          ),
                        ),
                        ProfileMenuItem(
                          icon: Icons.delete_outline,
                          title: 'Hapus Akun',
                          titleColor: const Color(0xFFC62828),
                          iconColor: const Color(0xFFC62828),
                          iconBackgroundColor: const Color(0xFFFFDAD6),
                          onTap: () => _showMessage(
                            context,
                            'Penghapusan akun memerlukan konfirmasi email.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 7. Tombol Keluar dari Akun
                    OutlinedButton.icon(
                      onPressed: () {
                        if (isLoggedIn) {
                          _confirmSignOut();
                        } else {
                          _showMessage(
                            context,
                            'Anda berada dalam mode demo. Masuk untuk menyimpan data akun Anda.',
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: isLoggedIn
                            ? const Color(0xFFC62828)
                            : AppTheme.forest,
                        side: const BorderSide(color: Color(0xFFE8EEE9)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Keluar dari Akun',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. Footer Info Versi
                    Column(
                      children: [
                        Text(
                          ProfileDemoData.appVersion,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.mutedText,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ProfileDemoData.appTagline,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.mutedText.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 10,
                              ),
                        ),
                      ],
                    ),
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
