import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week3_async/pages/stats_page.dart';
import 'package:week3_async/providers/stats_provider.dart';

void main() {
  testWidgets('StatsPage menampilkan data statistik', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(
            () => TestStatsNotifier(),
          ),
        ],
        child: const MaterialApp(
          home: StatsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pengguna Aktif: 120'), findsOneWidget);
    expect(find.text('Pesanan Hari Ini: 45'), findsOneWidget);
    expect(find.text('Pendapatan: Rp2.500.000'), findsOneWidget);
  });
}

// Notifier khusus untuk widget test agar hasilnya konsisten.
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