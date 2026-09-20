import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.title, {required this.id, this.done = false});
  final int id;
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, id: id, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  int _nextId = 0;
  @override
  List<Todo> build() => const [];

  void add(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    state = [...state, Todo(trimmed, id: _nextId++)];
  }

  void toggle(int id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(done: !todo.done) else todo,
    ];
  }

  void remove(int id) => state = state.where((todo) => todo.id != id).toList();
}

final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);

class TodoFilterNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setIncompleteOnly(bool value) => state = value;
}

final todoFilterProvider = NotifierProvider<TodoFilterNotifier, bool>(
  TodoFilterNotifier.new,
);

// Provider turunan bereaksi terhadap perubahan daftar maupun pilihan filter.
final filteredTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final incompleteOnly = ref.watch(todoFilterProvider);
  return List.unmodifiable(
    incompleteOnly ? todos.where((todo) => !todo.done) : todos,
  );
});
