import 'package:flutter_test/flutter_test.dart';
import 'package:week_9/features/notes/domain/filter_notes.dart';
import 'package:week_9/features/notes/domain/note.dart';

void main() {
  const sampleNotes = [
    Note(id: '1', title: 'Belajar Flutter Clean Architecture', body: 'Isi 1'),
    Note(id: '2', title: 'Catatan Rapat Mingguan', body: 'Isi 2'),
    Note(id: '3', title: 'Dart Pure Function', body: 'Isi 3'),
  ];

  group('filterNotes', () {
    test('mengembalikan note yang cocok secara case-insensitive', () {
      final result = filterNotes(sampleNotes, 'fLuTtEr');

      expect(result.length, 1);
      expect(result.first.id, '1');
    });

    test(
      'mengembalikan semua notes jika query kosong atau hanya whitespace',
      () {
        expect(filterNotes(sampleNotes, '').length, 3);
        expect(filterNotes(sampleNotes, '   ').length, 3);
      },
    );

    test('mengembalikan list kosong jika tidak ada title yang cocok', () {
      final result = filterNotes(sampleNotes, 'React Native');

      expect(result, isEmpty);
    });
  });
}
