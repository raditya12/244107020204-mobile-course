import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/todo_provider.dart';
import 'package:week3_todo/widgets/todo_tile.dart';

void main() {
  testWidgets('TodoTile menampilkan status dan meneruskan aksi', (
    tester,
  ) async {
    var toggles = 0;
    var deletes = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoTile(
            todo: Todo('Tugas selesai', id: 7, done: true),
            onToggle: () => toggles++,
            onDelete: () => deletes++,
          ),
        ),
      ),
    );
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(
      tester.widget<Text>(find.text('Tugas selesai')).style?.decoration,
      TextDecoration.lineThrough,
    );
    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byIcon(Icons.delete));
    expect(toggles, 1);
    expect(deletes, 1);
  });
}
