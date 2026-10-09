import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';

final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    return ref.watch(noteRepositoryProvider).fetchNotes();
  }

  Future<void> add(String title, String body) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
      return ref.read(noteRepositoryProvider).fetchNotes();
    });
  }

  Future<void> remove(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(noteRepositoryProvider).deleteNote(id);
      return ref.read(noteRepositoryProvider).fetchNotes();
    });
  }

  Future<int> syncAll() async {
    final repo = ref.read(noteRepositoryProvider);
    final count = await ref.read(syncServiceProvider).sync(repo);
    state = await AsyncValue.guard(() => repo.fetchNotes());
    ref.invalidate(dirtyCountProvider);
    return count;
  }
}

final dirtyCountProvider = FutureProvider<int>((ref) async {
  ref.watch(notesProvider);
  return ref.watch(noteRepositoryProvider).countDirty();
});

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catatan Baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyCtrl,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await ref
                  .read(notesProvider.notifier)
                  .add(titleCtrl.text.trim(), bodyCtrl.text.trim());
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
          content: Text('Menyinkronkan...'),
          duration: Duration(seconds: 1)),
    );
    final count = await ref.read(notesProvider.notifier).syncAll();
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(count == 0
            ? 'Tidak ada catatan yang perlu disinkronkan.'
            : '$count catatan berhasil disinkronkan'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, WidgetRef ref, Note n) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text('Hapus "${n.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok == true && n.id != null) {
      await ref.read(notesProvider.notifier).remove(n.id!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          dirty.when(
            data: (c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Chip(
                  avatar: Icon(
                    c == 0 ? Icons.cloud_done : Icons.cloud_upload,
                    size: 18,
                    color: c == 0 ? Colors.green : Colors.orange,
                  ),
                  label: Text('Dirty: $c'),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: 'Sync',
            icon: const Icon(Icons.sync),
            onPressed: () => _handleSync(context, ref),
          ),
        ],
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada catatan.\nTekan + untuk menambah.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final n = list[i];
              return NoteTile(
                note: n,
                onDelete: () => _confirmDelete(ctx, ref, n),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}