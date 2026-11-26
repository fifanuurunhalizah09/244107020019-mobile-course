import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:campus_notify/ai/ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiService Test Suite', () {
    test('mengembalikan fallback offline saat API Key belum diatur', () async {
      final service = AiService();
      final answer = await service.ask('Jadwal kuliah hari Senin?');

      expect(answer, contains('Jadwal kuliah Senin'));
    });

    test(
      'mengembalikan jawaban sesuai API response saat sukses (200 OK)',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.url.queryParameters['key'], 'test_gemini_key');
          expect(request.headers['Content-Type'], 'application/json');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(
            body['system_instruction']['parts'][0]['text'],
            contains('asisten cerdas kampus'),
          );

          return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': 'Pendaftaran KRS dibuka sampai hari Jumat.'},
                    ],
                  },
                },
              ],
            }),
            200,
          );
        });

        final service = AiService(
          client: mockClient,
          apiKey: 'test_gemini_key',
        );

        final answer = await service.ask('Kapan batas KRS?');
        expect(answer, 'Pendaftaran KRS dibuka sampai hari Jumat.');
      },
    );

    test('askStream mengalirkan token/kata secara bertahap', () async {
      final service = AiService();
      final chunks = <String>[];

      await for (final chunk in service.askStream(
        'Jadwal kuliah hari Senin?',
      )) {
        chunks.add(chunk);
      }

      expect(chunks.isNotEmpty, true);
      expect(chunks.last, contains('Jadwal kuliah Senin'));
    });

    test(
      'recognizeText dan speechToText mengembalikan respons yang valid',
      () async {
        final service = AiService();

        final ocrResult = await service.recognizeText('ktm.png');
        expect(ocrResult, contains('OCR Berhasil'));

        final sttResult = await service.speechToText('audio.m4a');
        expect(sttResult, contains('KRS'));
      },
    );
  });
}
