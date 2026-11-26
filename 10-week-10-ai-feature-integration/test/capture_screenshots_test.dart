import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/features/chat_screen.dart';

void main() {
  testWidgets('Capture screenshots for Week 10 AI features', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final key = GlobalKey();

    Future<void> takeScreenshot(String fileName) async {
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        final file = File('screenshots/$fileName');
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(bytes);
      });
    }

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: RepaintBoundary(key: key, child: const ChatScreen()),
      ),
    );

    // 1. Tampilan Awal Chat AI & Quick Prompts
    await takeScreenshot('01_ai_chat_screen.png');

    // 2. Interaksi Pengiriman Pertanyaan & Respons AI
    final chatInputFinder = find.byWidgetPredicate(
      (w) =>
          w is TextField &&
          w.decoration?.hintText == 'Tanyakan sesuatu tentang kampus...',
    );

    await tester.enterText(chatInputFinder, 'Jadwal kuliah hari Senin?');
    await tester.tap(find.byIcon(Icons.send));
    for (int i = 0; i < 25; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await takeScreenshot('02_ai_chat_conversation.png');

    // 3. Dialog Pengaturan API Key Secure Storage
    await tester.tap(find.byIcon(Icons.vpn_key_outlined));
    await tester.pumpAndSettle();
    await takeScreenshot('03_api_key_settings.png');
    // Tutup dialog
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // 4. Deteksi Privasi (Data Sensitif NIK)
    await tester.enterText(chatInputFinder, 'Kirim NIK 3507123456789012');
    await tester.tap(find.byIcon(Icons.send), warnIfMissed: false);
    await tester.pumpAndSettle();
    await takeScreenshot('04_privacy_warning.png');
  });
}
