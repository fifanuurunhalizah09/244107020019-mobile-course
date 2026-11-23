import 'package:flutter_test/flutter_test.dart';
import 'package:week_9/features/notes/domain/filter_notes.dart';
import 'package:week_9/features/notes/domain/note.dart';

void main() {
  const sampleNotes = [
    Note(
      id: '1',
      title: 'Belanja Bulanan Supermarket',
      body: 'Beras, minyak, gula',
    ),
    Note(id: '2', title: 'Daftar Belanja Mingguan', body: 'Sayur, buah, susu'),
    Note(
      id: '3',
      title: 'Belajar Flutter Clean Architecture',
      body: 'Layer domain, data, presentation',
    ),
    Note(id: '4', title: 'Catatan Rapat Mingguan', body: 'Evaluasi sprint'),
  ];

  group('search_filter_test - Pengujian Fungsi filterNotes', () {
    test('filter abaikan huruf besar/kecil', () {
      // Menguji pencarian dengan 'belanja' (lowercase) harus mencocokkan id 1 dan 2
      final result = filterNotes(sampleNotes, 'belanja');
      expect(result, hasLength(2));
      expect(result[0].id, '1');
      expect(result[1].id, '2');

      // Menguji dengan campuran uppercase 'BELANJA'
      final resultUpper = filterNotes(sampleNotes, 'BELANJA');
      expect(resultUpper, hasLength(2));
    });

    test('query tak cocok kembalikan kosong', () {
      // Menguji query yang tidak ada menghasilkan list kosong (empty state trigger)
      final result = filterNotes(sampleNotes, 'zzz-tak-ada');
      expect(result, isEmpty);
    });

    test('query kosong kembalikan semua notes', () {
      final result = filterNotes(sampleNotes, '');
      expect(result, hasLength(sampleNotes.length));
    });

    test('query hanya whitespace kembalikan semua notes', () {
      final result = filterNotes(sampleNotes, '    ');
      expect(result, hasLength(sampleNotes.length));
    });

    test('filter cocok sebagian kata di tengah judul', () {
      final result = filterNotes(sampleNotes, 'Flutter');
      expect(result, hasLength(1));
      expect(result.first.title, contains('Flutter'));
    });
  });
}
