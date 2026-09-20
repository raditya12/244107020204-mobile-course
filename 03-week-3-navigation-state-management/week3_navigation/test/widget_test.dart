import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:week3_navigation/main.dart';

void main() {
  testWidgets('Home, detail, back, dan akses path detail langsung', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Item 3'));
    await tester.pumpAndSettle();
    expect(find.text('Detail 3'), findsOneWidget);
    expect(find.text('Anda membuka item dengan id: 3'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    final router =
        tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig!
            as GoRouter;
    router.go('/detail/9');
    await tester.pumpAndSettle();
    expect(find.text('Detail 9'), findsOneWidget);
    expect(find.text('Anda membuka item dengan id: 9'), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/detail/9');

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
}
