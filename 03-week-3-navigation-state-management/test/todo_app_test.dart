import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/main.dart';
import 'package:week3_todo/providers/stats_provider.dart';
import 'package:week3_todo/providers/todo_provider.dart';
import 'package:week3_todo/router/app_router.dart';
import 'package:week3_todo/widgets/todo_tile.dart';

Future<void> addTodo(WidgetTester tester, String title) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.text('Tambah'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);
    await addTodo(tester, 'Kerjakan PR minggu 3');
    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
    expect(find.byType(TodoTile), findsOneWidget);
  });

  testWidgets('filter toggle dan hapus mengubah tugas yang tepat', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await addTodo(tester, 'Tugas A');
    await addTodo(tester, 'Tugas B');
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Tugas A'), findsNothing);
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada tugas yang belum selesai'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      tester.widgetList<Checkbox>(find.byType(Checkbox)).every((c) => c.value!),
      isTrue,
    );
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Tugas A'), findsOneWidget);
    expect(find.text('Tugas B'), findsNothing);
  });

  testWidgets('navigasi, back, dan state bertahan antarhalaman', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(() => StatsNotifier(randomValue: () => 0.9)),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await addTodo(tester, 'Tetap tersimpan');
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Total pengguna'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(container.read(todoListProvider).single.title, 'Tetap tersimpan');
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Tetap tersimpan'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    await tester.tap(find.byIcon(Icons.bar_chart));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();
    expect(find.text('Tetap tersimpan'), findsOneWidget);
  });

  testWidgets('akses langsung /stats dan kembali ke daftar', (tester) async {
    final router = createRouter(initialLocation: '/stats');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
          statsProvider.overrideWith(
            () => StatsNotifier(randomValue: () => 0.9),
          ),
        ],
        child: const MyApp(),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/stats');
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Total pengguna'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/');
    expect(find.text('Belum ada tugas'), findsOneWidget);
  });
}
