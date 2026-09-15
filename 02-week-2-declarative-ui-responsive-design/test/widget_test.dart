import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';
import 'package:responsive_dashboard/profile_card_example.dart';

void main() {
  testWidgets('warm-up profile menampilkan seluruh data mahasiswa', (
    tester,
  ) async {
    await tester.pumpWidget(const ProfileApp());

    expect(find.text('Raditya Riefki'), findsOneWidget);
    expect(find.text('244107020204'), findsOneWidget);
    expect(find.text('TI-3E'), findsOneWidget);
    expect(find.text('radityariefki5@gmail.com'), findsOneWidget);
  });

  testWidgets('dashboard satu kolom di layar sempit', (tester) async {
    await _setSurfaceSize(tester, const Size(400, 800));
    await tester.pumpWidget(const DashboardApp());

    expect(find.byKey(const Key('academic-grid-1')), findsOneWidget);
    final firstCard = tester.getTopLeft(find.byKey(const Key('info-card-0')));
    final secondCard = tester.getTopLeft(find.byKey(const Key('info-card-1')));
    expect(secondCard.dx, firstCard.dx);
    expect(secondCard.dy, greaterThan(firstCard.dy));
  });

  testWidgets('dashboard dua kolom di layar lebar', (tester) async {
    await _setSurfaceSize(tester, const Size(1200, 800));
    await tester.pumpWidget(const DashboardApp());

    expect(find.byKey(const Key('academic-grid-2')), findsOneWidget);
    final firstCard = tester.getTopLeft(find.byKey(const Key('info-card-0')));
    final secondCard = tester.getTopLeft(find.byKey(const Key('info-card-1')));
    expect(secondCard.dx, greaterThan(firstCard.dx));
    expect(secondCard.dy, firstCard.dy);
    expect(
      tester.getSize(find.byKey(const Key('info-card-0'))).width,
      greaterThan(500),
    );
  });

  testWidgets('toggle mengaktifkan dark theme', (tester) async {
    await tester.pumpWidget(const DashboardApp());

    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.light,
    );
    await tester.tap(find.byKey(const Key('theme-switch')));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('informasi penting memiliki label aksesibilitas', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const DashboardApp());

    expect(
      find.bySemanticsLabel(
        RegExp(
          'Student profile, Raditya Riefki, NIM 244107020204, class TI-3E',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Assignments: 8. 3 due this week')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('Dark mode')), findsOneWidget);
    semantics.dispose();
  });
}

Future<void> _setSurfaceSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}
