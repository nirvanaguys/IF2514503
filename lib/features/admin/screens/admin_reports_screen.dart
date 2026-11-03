import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/theme/app_theme.dart';
import '../models/admin_models.dart';
import '../services/admin_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _adminService = AdminService();
  List<ProductReportModel> _reports = [];
  bool _isLoading = false;
  String _selectedFilter = 'Semua';

  final List<String> _filters = ['Semua', 'pending', 'reviewed', 'dismissed'];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final reports = await _adminService.fetchAllReports(
      statusFilter: _selectedFilter == 'Semua' ? null : _selectedFilter,
    );
    if (mounted) {
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    }
  }

  String _filterLabel(String filter) {
    switch (filter) {
      case 'pending':
        return 'Pending';
      case 'reviewed':
        return 'Ditindak';
      case 'dismissed':
        return 'Diabaikan';
      default:
        return 'Semua';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? get _currentAdminId {
    try {
      return supa.Supabase.instance.client.auth.currentUser?.id;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleAction(
    ProductReportModel report,
    String actionType,
  ) async {
    final adminId = _currentAdminId;
    if (adminId == null) return;

    final actionLabels = {
      'deactivate_product': 'Nonaktifkan Produk',
      'warn_seller': 'Beri Peringatan',
      'dismiss_report': 'Abaikan Laporan',
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(actionLabels[actionType] ?? actionType),
        content: Text(
          actionType == 'deactivate_product'
              ? 'Produk "${report.productName ?? 'ini'}" akan dinonaktifkan dari katalog.'
              : actionType == 'warn_seller'
              ? 'Peringatan akan dicatat untuk penjual produk ini.'
              : 'Laporan ini akan ditandai sebagai diabaikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: actionType == 'dismiss_report'
                  ? AppTheme.mutedText
                  : actionType == 'deactivate_product'
                  ? const Color(0xFFC62828)
                  : AppTheme.forest,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    bool success = false;
    switch (actionType) {
      case 'deactivate_product':
        success = await _adminService.deactivateProduct(
          adminId: adminId,
          reportId: report.id,
          productId: report.productId,
        );
        break;
      case 'warn_seller':
        success = await _adminService.warnSeller(
          adminId: adminId,
          reportId: report.id,
          productId: report.productId,
        );
        break;
      case 'dismiss_report':
        success = await _adminService.dismissReport(
          adminId: adminId,
          reportId: report.id,
          productId: report.productId,
        );
        break;
    }

    if (success) {
      _showMessage('Tindakan berhasil diterapkan.');
      _loadReports();
    } else {
      _showMessage('Gagal menerapkan tindakan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Moderasi Laporan',
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
      body: Column(
        children: [
          // Filter tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(f)),
                      selected: isSelected,
                      selectedColor: AppTheme.forest,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF101F16),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      backgroundColor: AppTheme.paleGreen,
                      onSelected: (val) {
                        if (val) {
                          setState(() => _selectedFilter = f);
                          _loadReports();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Reports list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reports.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 56,
                            color: AppTheme.forest,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Tidak Ada Laporan',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Belum ada laporan produk yang perlu ditinjau.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadReports,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reports.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        return _buildReportCard(report);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ProductReportModel report) {
    final isPending = report.status == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? const Color(0xFFC62828).withValues(alpha: 0.3)
              : const Color(0xFFE8EEE9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  report.productName ??
                      'Produk #${report.productId.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFFEBEE)
                      : report.status == 'reviewed'
                      ? AppTheme.softGreen
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isPending
                        ? const Color(0xFFC62828)
                        : report.status == 'reviewed'
                        ? AppTheme.forest
                        : AppTheme.mutedText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Alasan & pelapor
          Text(
            'Alasan: ${report.reason}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
          ),
          if (report.description != null && report.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              report.description!,
              style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Pelapor: ${report.reporterName ?? 'Anonim'} • '
            '${_formatDate(report.createdAt)}',
            style: const TextStyle(fontSize: 11, color: AppTheme.mutedText),
          ),

          // Tombol aksi (hanya untuk pending)
          if (isPending) ...[
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleAction(report, 'dismiss_report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.mutedText,
                      side: const BorderSide(color: Color(0xFFE8EEE9)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Abaikan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleAction(report, 'warn_seller'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9A6700),
                      side: const BorderSide(color: Color(0xFF9A6700)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Peringatan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _handleAction(report, 'deactivate_product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Nonaktifkan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}
