import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_notify/main.dart';

void main() {
  testWidgets('App bisa dibuka tanpa crash', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CampusNotifyApp()),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}