import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/announcement_repository.dart';
import '../models/announcement.dart';

// Provider repository
final announcementRepositoryProvider =
    Provider<AnnouncementRepository>((ref) => AnnouncementRepository());

// Filter kategori
final selectedCategoryProvider =
    StateProvider<AnnouncementCategory?>((ref) => null);

// List pengumuman (async)
final announcementListProvider =
    AsyncNotifierProvider<AnnouncementListNotifier, List<Announcement>>(
  AnnouncementListNotifier.new,
);

class AnnouncementListNotifier extends AsyncNotifier<List<Announcement>> {
  @override
  Future<List<Announcement>> build() async {
    return ref.watch(announcementRepositoryProvider).fetchAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(announcementRepositoryProvider).fetchAll(),
    );
  }

  Future<void> markAsRead(String id) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(
      current
          .map((a) => a.id == id ? a.copyWith(isRead: true) : a)
          .toList(),
    );
  }
}

// Filter berdasarkan kategori terpilih
final filteredAnnouncementsProvider = Provider<List<Announcement>>((ref) {
  final all = ref.watch(announcementListProvider).value ?? [];
  final selected = ref.watch(selectedCategoryProvider);

  if (selected == null) return all;
  return all.where((a) => a.category == selected).toList();
});

// Cari pengumuman berdasarkan ID
final announcementByIdProvider =
    FutureProvider.family<Announcement?, String>((ref, id) async {
  final repo = ref.watch(announcementRepositoryProvider);
  return repo.findById(id);
});