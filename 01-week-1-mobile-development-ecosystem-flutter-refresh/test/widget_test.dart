import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('displays the responsive student dashboard', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DashboardApp());

    expect(find.text('Student Dashboard'), findsOneWidget);
    expect(find.text('Courses'), findsOneWidget);
    expect(find.text('Assignments'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('GPA'), findsOneWidget);
    expect(find.byType(CupertinoSwitch), findsOneWidget);
  });

  testWidgets('toggles dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(const DashboardApp());

    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    await tester.tap(find.byType(CupertinoSwitch));
    await tester.pump();

    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });

  testWidgets('provides meaningful screen reader labels', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(const DashboardApp());

      expect(
        find.bySemanticsLabel(
          'Dark mode nonaktif, ketuk untuk beralih ke mode gelap',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Courses: 6'), findsOneWidget);
      expect(find.bySemanticsLabel('Assignments: 4'), findsOneWidget);
      expect(find.bySemanticsLabel('Attendance: 92%'), findsOneWidget);
      expect(find.bySemanticsLabel('GPA: 3.75'), findsOneWidget);

      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pump();

      expect(
        find.bySemanticsLabel(
          'Dark mode aktif, ketuk untuk beralih ke mode terang',
        ),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
  });
}
