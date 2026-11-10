import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      // Mock: belum pakai SQLite
      final now = DateTime.now();
      final data = [
        NoteModel(title: 'Catatan 1', updatedAt: now),
        NoteModel(title: 'Catatan 2', updatedAt: now),
      ];
      final notes = data.map((m) => m.toEntity()).toList();
      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    try {
      final now = DateTime.now();
      final note = NoteModel(
        title: title,
        body: body,
        updatedAt: now,
        dirty: true,
      ).toEntity();

      return (note: note, failure: null);
    } catch (e) {
      return (
        note: null,
        failure: LocalFailure('Gagal menyimpan catatan: $e'),
      );
    }
  }
}