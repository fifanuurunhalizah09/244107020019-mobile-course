import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_9/features/notes/presentation/notes_page.dart';

void main() {
  testWidgets('Capture screenshots for 3 queries', (tester) async {
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

        final file1 = File('screenshots/$fileName');
        file1.parent.createSync(recursive: true);
        file1.writeAsBytesSync(bytes);

        final file2 = File('../screenshots/$fileName');
        file2.parent.createSync(recursive: true);
        file2.writeAsBytesSync(bytes);
      });
    }

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: RepaintBoundary(key: key, child: const NotesPage()),
      ),
    );

    // 1. Query Kosong (Kondisi Awal)
    await takeScreenshot('01_query_kosong.png');

    // 2. Query Cocok ('flutter')
    await tester.enterText(find.byType(TextField), 'flutter');
    await takeScreenshot('02_query_cocok.png');

    // 3. Query Tidak Cocok / Empty State ('zzz-tak-ada')
    await tester.enterText(find.byType(TextField), 'zzz-tak-ada');
    await takeScreenshot('03_query_empty_state.png');
  });
}
