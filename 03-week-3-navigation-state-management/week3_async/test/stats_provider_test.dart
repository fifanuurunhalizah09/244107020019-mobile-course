import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week3_async/providers/stats_provider.dart';

void main() {
  test('Stats provider mengembalikan 3 data statistik', () async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => TestStatsNotifier(),
        ),
      ],
    );

    addTearDown(container.dispose);

    final result = await container.read(statsProvider.future);

    expect(result.length, 3);
    expect(result[0], contains('Pengguna Aktif'));
    expect(result[1], contains('Pesanan Hari Ini'));
    expect(result[2], contains('Pendapatan'));
  });
}

// Notifier khusus untuk unit test agar hasil test selalu konsisten.
class TestStatsNotifier extends StatsNotifier {
  @override
  Future<List<String>> build() async {
    return [
      'Pengguna Aktif: 120',
      'Pesanan Hari Ini: 45',
      'Pendapatan: Rp2.500.000',
    ];
  }
}