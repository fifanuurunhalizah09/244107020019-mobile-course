import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/connectivity.dart';
import '../data/local/post.dart';
import '../data/repositories/post_repository.dart';

final postRepositoryProvider =
    Provider<PostRepository>((ref) => PostRepository());

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() {
    return ref.watch(postRepositoryProvider).loadPostsCacheFirst();
  }

  Future<void> refreshFromNetwork() async {
    final forceOffline = ref.read(forceOfflineProvider);
    if (forceOffline) {
      throw Exception('Mode offline (forceOffline) aktif — refresh dibatalkan.');
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(postRepositoryProvider).refreshPostsInBackground());
  }
}

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts (Cache-first)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh dari network',
            onPressed: () =>
                ref.read(postsProvider.notifier).refreshFromNetwork(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ⬇️ Switch simulasi offline (sesuai jobsheet)
          SwitchListTile(
            title: const Text('Simulasi Offline (forceOffline)'),
            subtitle: const Text(
                'Aktifkan untuk menguji cache tanpa mematikan Wi-Fi sungguhan'),
            value: ref.watch(forceOfflineProvider),
            onChanged: (v) =>
                ref.read(forceOfflineProvider.notifier).state = v,
          ),
          const Divider(height: 1),
          Expanded(
            child: posts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada cache.\nSambungkan ke internet lalu tap refresh.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final p = list[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        child: Text('${p.id}'),
                      ),
                      title: Text(p.title,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(p.body,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}