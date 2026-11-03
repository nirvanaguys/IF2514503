import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../services/diagnosis_service.dart';

class DiagnosisResultScreen extends StatelessWidget {
  final DiagnosisResult result;

  const DiagnosisResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final hasAiResult = result.confidence != null;

    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      appBar: AppBar(
        title: const Text(
          'Hasil Diagnosis',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar
            if (result.imagePath != null && result.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  result.imagePath!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 220,
                    color: AppTheme.paleGreen,
                    child: const Center(
                      child: Icon(Icons.eco, size: 64, color: AppTheme.forest),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Status AI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasAiResult
                    ? AppTheme.softGreen
                    : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    hasAiResult ? Icons.check_circle : Icons.info_outline,
                    color: hasAiResult
                        ? AppTheme.forest
                        : const Color(0xFF9A6700),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasAiResult
                              ? 'Diagnosis Selesai'
                              : 'AI Belum Terintegrasi',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: hasAiResult
                                ? AppTheme.forest
                                : const Color(0xFF9A6700),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasAiResult
                              ? 'Tingkat keyakinan: ${(result.confidence! * 100).toStringAsFixed(1)}%'
                              : 'Gambar disimpan ke riwayat. Hasil analisis akan tersedia setelah AI aktif.',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasAiResult
                                ? AppTheme.forest
                                : const Color(0xFF9A6700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nama tanaman (jika teridentifikasi)
            if (result.plantName != null && result.plantName!.isNotEmpty) ...[
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
                      'Tanaman Teridentifikasi',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.plantName!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Ringkasan hasil
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
                    'Ringkasan Analisis',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.resultSummary,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Rekomendasi
            if (result.recommendation != null &&
                result.recommendation!.isNotEmpty)
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
                    const Row(
                      children: [
                        Icon(Icons.eco, size: 20, color: AppTheme.forest),
                        SizedBox(width: 8),
                        Text(
                          'Rekomendasi Perawatan',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.recommendation!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Waktu diagnosis
            Text(
              'Diagnosis pada: ${_formatDateTime(result.createdAt)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
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
    return '${dt.day} ${months[dt.month]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
