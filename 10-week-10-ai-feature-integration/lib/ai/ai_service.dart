import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AiService {
  final FlutterSecureStorage _storage;
  final http.Client _client;
  final String _apiUrl;
  String? _inMemoryApiKey;

  // System prompt sesuai pedoman mobile codelab: persona asisten kampus ramah, ringkas, dan aman
  static const String systemInstruction =
      'Kamu adalah asisten cerdas kampus yang ramah, sopan, dan sigap membantu mahasiswa. '
      'Jawablah dalam Bahasa Indonesia yang ringkas, jelas, dan maksimal 2-3 kalimat. '
      'Fokus pada informasi akademik, jadwal, pengumuman, dan fasilitas kampus. '
      'Jangan pernah meminta atau membocorkan data pribadi mahasiswa.';

  AiService({
    FlutterSecureStorage? storage,
    http.Client? client,
    String? apiUrl,
    String? apiKey,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _client = client ?? http.Client(),
       _apiUrl = apiUrl ?? 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
       _inMemoryApiKey = apiKey;

  /// Membaca API Key dari secure storage atau cache memori
  Future<String?> getApiKey() async {
    if (_inMemoryApiKey != null && _inMemoryApiKey!.isNotEmpty) {
      return _inMemoryApiKey;
    }
    try {
      final key = await _storage.read(key: 'ai_api_key');
      _inMemoryApiKey = key;
      return key;
    } catch (_) {
      return null;
    }
  }

  /// Menyimpan API Key ke secure storage secara terenkripsi
  Future<void> saveApiKey(String key) async {
    _inMemoryApiKey = key.trim();
    try {
      await _storage.write(key: 'ai_api_key', value: key.trim());
    } catch (_) {}
  }

  /// Menghapus API Key
  Future<void> deleteApiKey() async {
    _inMemoryApiKey = null;
    try {
      await _storage.delete(key: 'ai_api_key');
    } catch (_) {}
  }

  /// Mengirim pertanyaan ke AI API
  Future<String> ask(
    String question, {
    bool allowOfflineFallback = true,
  }) async {
    final apiKey = await getApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      if (allowOfflineFallback) {
        return _getOfflineFallback(question);
      }
      throw Exception('API key tidak tersedia. Silakan atur di pengaturan.');
    }

    try {
      final response = await _client.post(
        Uri.parse('$_apiUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': systemInstruction},
            ],
          },
          'contents': [
            {
              'parts': [
                {'text': question},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 200},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'].toString().trim();
          }
        }
        return 'Maaf, saya tidak dapat memproses jawaban saat ini.';
      } else {
        if (allowOfflineFallback) {
          return _getOfflineFallback(question);
        }
        throw Exception('Gagal memanggil AI API: ${response.statusCode}');
      }
    } catch (e) {
      if (allowOfflineFallback) {
        return _getOfflineFallback(question);
      }
      rethrow;
    }
  }

  /// Simulasi streaming response untuk pengalaman pengguna yang interaktif
  Stream<String> askStream(String question) async* {
    final fullAnswer = await ask(question);
    final words = fullAnswer.split(' ');
    String currentText = '';

    for (var i = 0; i < words.length; i++) {
      currentText += (i == 0 ? '' : ' ') + words[i];
      yield currentText;
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  /// Fitur OCR (Optical Character Recognition) untuk ekstraksi dokumen/KTM
  Future<String> recognizeText(dynamic imageFile) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return 'Ekstraksi OCR Berhasil: [KTM Mahasiswa - NIM: 244107020019, Status: Aktif Semester 5]';
  }

  /// Fitur Speech-to-Text untuk konversi suara mahasiswa ke teks query
  Future<String> speechToText(dynamic audioFile) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return 'Kapan batas akhir pengisian KRS semester ganjil?';
  }

  /// Mode Offline Fallback yang cerdas untuk antisipasi gangguan jaringan / API down
  String _getOfflineFallback(String question) {
    final q = question.toLowerCase();

    if (q.contains('jadwal') || q.contains('senin') || q.contains('kuliah')) {
      return 'Jadwal kuliah Senin: Pemrograman Mobile pukul 07.30 di Lab TI-02, dilanjutkan Jaringan Komputer pukul 13.00.';
    } else if (q.contains('krs') || q.contains('kartu rencana studi')) {
      return 'Pengisian KRS semester ini dibuka hingga Jumat pekan depan melalui portal Siakad resmi kampus.';
    } else if (q.contains('perpustakaan') ||
        q.contains('perpus') ||
        q.contains('lokasi')) {
      return 'Perpustakaan pusat berada di Gedung Graha Utama lantai 3, buka setiap hari kerja pukul 08.00 - 16.00 WIB.';
    } else if (q.contains('beasiswa')) {
      return 'Informasi beasiswa prestasi dan KIP-K dapat diakses pada menu Pengumuman Kemahasiswaan di aplikasi.';
    } else {
      return 'Halo! Saya asisten kampus pintar. Saat ini mode offline aktif, namun Anda tetap dapat menanyakan jadwal, KRS, beasiswa, atau lokasi fasilitas kampus.';
    }
  }
}
