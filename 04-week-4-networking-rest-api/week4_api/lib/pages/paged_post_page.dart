import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/paged_posts.dart';
import '../data/network_errors.dart';
import 'widgets/post_tile.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() =>
      _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);

    // Error state — hanya kalau belum ada data sama sekali
    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Post Explorer'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref
                  .read(pagedPostsProvider.notifier)
                  .loadFirstPage(),
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  friendlyErrorMessage(state.error!),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref
                      .read(pagedPostsProvider.notifier)
                      .loadFirstPage(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Loading pertama kali
    if (state.items.isEmpty && state.isLoadingMore) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post Explorer')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Explorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(pagedPostsProvider.notifier)
                .loadFirstPage(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(pagedPostsProvider.notifier).loadFirstPage(),
        child: ListView.builder(
          controller: _controller,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.items.length + 1,
          itemBuilder: (context, index) {
            // Item terakhir = indikator bawah
            if (index == state.items.length) {
              if (!state.hasMore) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Semua data sudah dimuat.',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 13),
                    ),
                  ),
                );
              }
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: CircularProgressIndicator()),
              );
            }

            final post = state.items[index];
            return PostTile(
              post: post,
              onTap: () => context.push('/post/${post.id}'),
            );
          },
        ),
      ),
    );
  }
}