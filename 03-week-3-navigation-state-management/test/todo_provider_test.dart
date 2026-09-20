import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/todo_provider.dart';

void main() {
  test('filter reaktif, identitas stabil, dan state lama tidak dimutasi', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(todoListProvider.notifier);
    notifier.add('Selesai');
    notifier.add('Belum selesai');
    final original = container.read(todoListProvider);
    notifier.toggle(original.first.id);
    expect(original.first.done, isFalse);

    container.read(todoFilterProvider.notifier).setIncompleteOnly(true);
    expect(container.read(filteredTodosProvider).single.title, 'Belum selesai');
    notifier.toggle(container.read(filteredTodosProvider).single.id);
    expect(container.read(filteredTodosProvider), isEmpty);
    notifier.toggle(original.last.id);
    notifier.remove(container.read(filteredTodosProvider).single.id);
    expect(container.read(todoListProvider).single.title, 'Selesai');
    container.read(todoFilterProvider.notifier).setIncompleteOnly(false);
    expect(container.read(filteredTodosProvider).single.title, 'Selesai');
  });

  test('judul kosong ditolak, judul dirapikan, ID tidak dipakai ulang', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(todoListProvider.notifier);
    notifier.add('   ');
    expect(container.read(todoListProvider), isEmpty);
    notifier.add('  Tugas  ');
    final todo = container.read(todoListProvider).single;
    expect(todo.title, 'Tugas');
    notifier.remove(todo.id);
    notifier.add('Baru');
    expect(container.read(todoListProvider).single.id, isNot(todo.id));
  });
}
