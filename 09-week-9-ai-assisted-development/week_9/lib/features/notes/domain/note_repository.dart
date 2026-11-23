import 'note.dart';

abstract class NoteRepository {
  Future<List<Note>> getAllNotes();
}
