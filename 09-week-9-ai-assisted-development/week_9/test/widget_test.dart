import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_9/features/notes/presentation/notes_page.dart';

void main() {
  group('NotesPage Widget Test', () {
    testWidgets('menampilkan daftar catatan awal saat query kosong', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NotesPage()));

      // Verifikasi judul AppBar dan TextField pencarian ada
      expect(find.text('Notes Search (AI)'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verifikasi beberapa catatan muncul pada kondisi awal
      expect(find.text('Belajar Flutter Clean Architecture'), findsOneWidget);
      expect(find.text('Catatan Rapat Mingguan'), findsOneWidget);
      expect(find.text('Dart Pure Function'), findsOneWidget);
      expect(find.text('Catatan tidak ditemukan'), findsNothing);
    });

    testWidgets('menampilkan hasil pencarian saat query cocok', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: NotesPage()));

      // Ketik query pencarian 'flutter'
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.pump();

      // Verifikasi hanya catatan relevan yang tampil
      expect(find.text('Belajar Flutter Clean Architecture'), findsOneWidget);
      expect(find.text('Catatan Rapat Mingguan'), findsNothing);
      expect(find.text('Catatan tidak ditemukan'), findsNothing);
    });

    testWidgets('menampilkan empty state saat query tidak cocok', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: NotesPage()));

      // Ketik query yang tidak cocok dengan judul mana pun
      await tester.enterText(find.byType(TextField), 'zzz-tak-ada-di-catatan');
      await tester.pump();

      // Verifikasi Empty State muncul dengan icon dan teks yang tepat
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Catatan tidak ditemukan'), findsOneWidget);

      // Verifikasi tidak ada ListTile catatan yang ditampilkan
      expect(find.byType(ListTile), findsNothing);
    });
  });
}
