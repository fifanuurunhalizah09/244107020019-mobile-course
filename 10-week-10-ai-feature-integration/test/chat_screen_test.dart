import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/chat_screen.dart';

void main() {
  group('ChatScreen Widget Test', () {
    testWidgets('menampilkan header dan sapaan awal asisten AI', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

      // Verifikasi judul AppBar & mode
      expect(find.text('Asisten AI Kampus'), findsOneWidget);
      expect(find.text('Mode Cerdas Offline Aktif'), findsOneWidget);

      // Verifikasi pesan sapaan bot ada
      expect(
        find.textContaining('Halo! Saya Asisten AI Kampus'),
        findsOneWidget,
      );

      // Verifikasi input field & tombol kirim
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('menampilkan chip pertanyaan cepat (quick prompts)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

      expect(find.text('Jadwal kuliah hari Senin?'), findsOneWidget);
      expect(find.text('Info pengisian KRS semester ini'), findsOneWidget);
    });

    testWidgets('mencegah pengiriman data sensitif dan memicu dialog privasi', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

      // Input teks yang memuat NIK 16 digit
      await tester.enterText(
        find.byType(TextField),
        'Halo ini NIK saya 3507123456789012 tolong cek data beasiswa',
      );
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Verifikasi dialog peringatan privasi muncul
      expect(find.text('Peringatan Privasi'), findsOneWidget);
      expect(
        find.textContaining('terdeteksi memuat informasi sensitif'),
        findsOneWidget,
      );
    });

    testWidgets('membuka dialog pengaturan API Key saat ikon kunci ditekan', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ChatScreen()));

      await tester.tap(find.byIcon(Icons.vpn_key_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan AI API Key'), findsOneWidget);
      expect(find.text('Simpan'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });
  });
}
