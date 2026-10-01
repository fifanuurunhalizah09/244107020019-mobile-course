import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

// ConsumerWidget digunakan agar halaman dapat membaca provider Riverpod.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch digunakan agar UI otomatis diperbarui ketika state berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      body: statsAsync.when(
        // Tampilan ketika data masih dimuat.
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        // Tampilan ketika terjadi error.
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat data: $error'),
              const SizedBox(height: 12),

              // read digunakan di callback untuk menjalankan method retry.
              FilledButton(
                onPressed: () {
                  ref.read(statsProvider.notifier).retry();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),

        // Tampilan ketika data berhasil diperoleh.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(stats[index]),
            );
          },
        ),
      ),
    );
  }
}