import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(DashboardCard);
    expect(cards, findsNWidgets(4));

    final firstCardWidth = tester.getSize(cards.first).width;
    expect(firstCardWidth, lessThan(700));
  });

  testWidgets('Dashboard dua kolom di layar lebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(DashboardCard);
    expect(cards, findsNWidgets(4));

    final firstCardWidth = tester.getSize(cards.first).width;
    expect(firstCardWidth, greaterThan(500));
  });
}