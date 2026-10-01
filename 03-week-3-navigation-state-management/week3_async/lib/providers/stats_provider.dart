import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier yang mengelola data statistik secara asynchronous.
class StatsNotifier extends AsyncNotifier<List<String>> {
  // build() dijalankan saat provider pertama kali digunakan.
  @override
  Future<List<String>> build() {
    return _fetchStats();
  }

  // Mensimulasikan proses mengambil data statistik dari server.
  Future<List<String>> _fetchStats() async {
    // Simulasi delay selama 2 detik.
    await Future.delayed(const Duration(seconds: 2));

    // Simulasi kemungkinan gagal sebesar 30%.
    final random = Random();

    if (random.nextDouble() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    // Data dikembalikan jika proses berhasil.
    return [
      'Pengguna Aktif: 120',
      'Pesanan Hari Ini: 45',
      'Pendapatan: Rp2.500.000',
    ];
  }

  // Menjalankan pengambilan data kembali ketika tombol retry ditekan.
  Future<void> retry() async {
    // Mengubah state menjadi loading.
    state = const AsyncLoading();

    // Menjalankan pengambilan data dan menangkap error.
    state = await AsyncValue.guard(_fetchStats);
  }
}

// Provider untuk StatsNotifier.
final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);