import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/errors/app_exception.dart';
import '../../subscription/services/subscription_service.dart';

/// Model hasil diagnosis.
class DiagnosisResult {
  final String id;
  final String userId;
  final String? imagePath;
  final String? plantName;
  final String resultSummary;
  final double? confidence;
  final String? recommendation;
  final DateTime createdAt;

  const DiagnosisResult({
    required this.id,
    required this.userId,
    this.imagePath,
    this.plantName,
    required this.resultSummary,
    this.confidence,
    this.recommendation,
    required this.createdAt,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      imagePath: json['image_path'] as String?,
      plantName: json['plant_name'] as String?,
      resultSummary: json['result_summary'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble(),
      recommendation: json['recommendation'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Service diagnosis tanaman.
///
/// Arsitektur siap menerima AI provider apa pun.
/// Saat ini menggunakan placeholder — hasil diagnosis akan menjelaskan
/// bahwa AI belum terintegrasi.
class DiagnosisService {
  final supa.SupabaseClient? _client;
  final SubscriptionService _subscriptionService = SubscriptionService();

  DiagnosisService({supa.SupabaseClient? client})
    : _client = client ?? _resolveClient();

  static supa.SupabaseClient? _resolveClient() {
    try {
      return supa.Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Menjalankan diagnosis pada gambar tanaman.
  ///
  /// Alur:
  /// 1. Cek kuota pengguna
  /// 2. Upload gambar ke storage
  /// 3. Kirim ke AI service (placeholder saat ini)
  /// 4. Simpan hasil ke diagnosis_history
  /// 5. Kurangi kuota
  Future<DiagnosisResult> diagnose({
    required String userId,
    required File imageFile,
    required String category,
  }) async {
    final client = _client;
    if (client == null) {
      throw const NetworkException('Supabase belum terhubung.');
    }

    // 1. Cek kuota (mengurangi kuota jika tersedia)
    try {
      await _subscriptionService.useQuota(userId);
    } catch (e) {
      if (e is AppException) rethrow;
      throw const ValidationException(
        'Gagal memeriksa kuota diagnosis. Silakan coba lagi.',
      );
    }

    // 2. Upload gambar ke storage
    String? imageUrl;
    try {
      final bytes = await imageFile.readAsBytes();
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await client.storage
          .from('diagnosis')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const supa.FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      imageUrl = client.storage.from('diagnosis').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Notice upload diagnosis image: $e');
      // Lanjutkan meskipun upload gagal — gambar opsional
    }

    // 3. Panggil AI service
    // TODO: Ganti dengan pemanggilan AI provider yang sesungguhnya
    // setelah keputusan provider ditetapkan.
    final aiResult = await _callAiService(
      imageUrl: imageUrl,
      imageBytes: await imageFile.readAsBytes(),
      category: category,
    );

    // 4. Simpan hasil ke database
    try {
      final payload = {
        'user_id': userId,
        'image_path': imageUrl,
        'plant_name': aiResult['plant_name'],
        'result_summary': aiResult['result_summary'],
        'confidence': aiResult['confidence'],
        'recommendation': aiResult['recommendation'],
      };

      final response = await client
          .from('diagnosis_history')
          .insert(payload)
          .select()
          .single();

      return DiagnosisResult.fromJson(response);
    } catch (e) {
      debugPrint('Notice save diagnosis: $e');
      // Kembalikan hasil meskipun gagal simpan
      return DiagnosisResult(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        imagePath: imageUrl,
        plantName: aiResult['plant_name'] as String?,
        resultSummary: aiResult['result_summary'] as String? ?? '',
        confidence: (aiResult['confidence'] as num?)?.toDouble(),
        recommendation: aiResult['recommendation'] as String?,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Placeholder AI service.
  /// Akan diganti dengan pemanggilan API sesungguhnya.
  Future<Map<String, dynamic>> _callAiService({
    String? imageUrl,
    Uint8List? imageBytes,
    required String category,
  }) async {
    // Simulasi waktu proses AI
    await Future.delayed(const Duration(seconds: 2));

    // Hasil placeholder — jujur bahwa AI belum terintegrasi
    return {
      'plant_name': null,
      'result_summary':
          'Analisis AI belum tersedia. '
          'Gambar berhasil disimpan ke riwayat diagnosis Anda. '
          'Setelah model AI diintegrasikan, diagnosis akan memberikan '
          'identifikasi penyakit dan rekomendasi perawatan.',
      'confidence': null,
      'recommendation':
          'Fitur rekomendasi perawatan akan tersedia setelah integrasi AI. '
          'Untuk sementara, pastikan tanaman mendapat cahaya, air, '
          'dan nutrisi yang cukup sesuai jenisnya.',
    };
  }

  /// Mengambil riwayat diagnosis pengguna.
  Future<List<DiagnosisResult>> fetchHistory(String userId) async {
    final client = _client;
    if (client == null) return [];

    try {
      final response = await client
          .from('diagnosis_history')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => DiagnosisResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Notice fetchHistory: $e');
      return [];
    }
  }

  /// Menghitung jumlah diagnosis yang sudah dilakukan pengguna.
  Future<int> countDiagnoses(String userId) async {
    final client = _client;
    if (client == null) return 0;

    try {
      final response = await client
          .from('diagnosis_history')
          .select('id')
          .eq('user_id', userId);
      return (response as List<dynamic>).length;
    } catch (e) {
      debugPrint('Notice countDiagnoses: $e');
      return 0;
    }
  }
}
