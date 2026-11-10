import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../models/announcement.dart';
import '../providers/announcement_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/announcement_card.dart';
import '../widgets/empty_state.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _fcmTokenPreview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupFcm());
  }

  Future<void> _setupFcm() async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example-campus-api.test'));

    await initFcmToken(
      onToken: (token) async {
        if (!mounted) return;
        setState(() {
          _fcmTokenPreview = shortToken(token);
        });
        try {
          await dio.post(
            '/devices',
            data: {'fcm_token': token, 'platform': 'android'},
          );
        } catch (_) {
          // Endpoint mock, abaikan
        }
      },
    );

    listenForeground((route) {
      if (!mounted) return;
      context.go(route);
    });

    await handleTerminated((route) {
      if (!mounted) return;
      context.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementListProvider);
    final filtered = ref.watch(filteredAnnouncementsProvider);
    final selected = ref.watch(selectedCategoryProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, Mahasiswa 👋',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Text(
              'Campus Notify',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
  icon: const Icon(Icons.logout),
  tooltip: 'Logout',
  onPressed: () => ref.read(authStateProvider.notifier).logout(),
),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(announcementListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Kartu FCM Token
            if (_fcmTokenPreview != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.notifications_active,
                            color: scheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifikasi Aktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'FCM: $_fcmTokenPreview',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Filter kategori
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(null, 'Semua', selected, scheme),
                      const SizedBox(width: 8),
                      ...AnnouncementCategory.values.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _filterChip(c, c.label, selected, scheme),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // List pengumuman
            announcementsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Gagal memuat',
                  subtitle: '$e',
                  actionLabel: 'Coba lagi',
                  onAction: () => ref
                      .read(announcementListProvider.notifier)
                      .refresh(),
                ),
              ),
              data: (_) {
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'Tidak ada pengumuman',
                      subtitle: selected == null
                          ? 'Belum ada pengumuman untuk saat ini.'
                          : 'Tidak ada pengumuman kategori ${selected.label}.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      return AnnouncementCard(
                        announcement: a,
                        onTap: () {
                          ref
                              .read(announcementListProvider.notifier)
                              .markAsRead(a.id);
                          context.go('/pengumuman/${a.id}');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    AnnouncementCategory? category,
    String label,
    AnnouncementCategory? selected,
    ColorScheme scheme,
  ) {
    final isSelected = category == selected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) =>
          ref.read(selectedCategoryProvider.notifier).state = category,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? scheme.onPrimary : scheme.onSurface,
      ),
      selectedColor: scheme.primary,
      backgroundColor: scheme.surfaceContainerHighest
          .withValues(alpha: 0.5),
    );
  }
}