import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/note_repository.dart';

/// Sinkronisasi catatan yang bertanda dirty (sesuai jobsheet).
///
/// Karena belum ada backend tulis, upload disimulasikan dengan delay.
/// Yang dinilai adalah mekanismenya: kapan dirty di-set, kapan dibersihkan.
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  // Simulasi upload: pada project nyata, kirim tiap catatan dirty
  // ke REST API di sini, lalu tandai bersih bila server menjawab 2xx.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

/// Provider supaya bisa diakses dari UI.
final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

class SyncService {
  Future<int> sync(NoteRepository repo) => syncNotes(repo);
}