import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/profile_demo_data.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showMessage(BuildContext context, String message) {
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
                    // 1. Profile User Card
                    ProfileUserCard(
                      userName: ProfileDemoData.userName,
                      email: ProfileDemoData.email,
                      planBadge: ProfileDemoData.planBadge,
                      onEditTap: () => _showMessage(
                        context,
                        'Edit profil belum tersedia pada versi demo.',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2. Bento Key Stats
                    ProfileStatsBento(
                      completedDiagnosis: ProfileDemoData.completedDiagnosis,
                      activeOrders: ProfileDemoData.activeOrders,
                      remainingQuota: ProfileDemoData.remainingQuota,
                      totalQuota: ProfileDemoData.totalQuota,
                      onDiagnosisStatsTap: () => _showMessage(
                        context,
                        'Riwayat diagnosis lengkap akan hadir di tahap riwayat.',
                      ),
                      onOrdersStatsTap: () => _showMessage(
                        context,
                        'Fitur pesanan sedang dalam pengembangan.',
                      ),
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
                          badgeText: '${ProfileDemoData.completedDiagnosis} Scan',
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
                          badgeText: '2 Dikirim',
                          badgeColor: const Color(0xFFD5EC9A),
                          badgeTextColor: const Color(0xFF3B4D0C),
                          onTap: () => _showMessage(
                            context,
                            'Fitur status pesanan belum tersedia.',
                          ),
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
                          onTap: () => _showMessage(
                            context,
                            'Fitur pendaftaran penjual belum tersedia.',
                          ),
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
                            'Pusat bantuan DaunKu (demo). Hubungi support@daunku.local',
                          ),
                        ),
                        ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Pengaturan Akun',
                          iconBackgroundColor: const Color(0xFFEFF3EE),
                          iconColor: const Color(0xFF101F16),
                          onTap: () => _showMessage(
                            context,
                            'Pengaturan akun belum tersedia pada versi demo.',
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
                            'Akun demo offline tidak dapat dihapus.',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 7. Logout Button
                    OutlinedButton.icon(
                      onPressed: () => _showMessage(
                        context,
                        'Keluar akun tidak diperlukan pada mode offline demo.',
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.forest,
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
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.mutedText,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ProfileDemoData.appTagline,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.mutedText.withValues(alpha: 0.7),
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
