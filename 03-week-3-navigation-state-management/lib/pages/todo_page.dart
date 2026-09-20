import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodosProvider);
    final incompleteOnly = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ToDo Riverpod')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Hanya yang belum selesai'),
            value: incompleteOnly,
            onChanged: ref.read(todoFilterProvider.notifier).setIncompleteOnly,
          ),
          Expanded(
            child: todos.isEmpty
                ? Center(
                    child: Text(
                      incompleteOnly
                          ? 'Tidak ada tugas yang belum selesai'
                          : 'Belum ada tugas',
                    ),
                  )
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return TodoTile(
                        key: ValueKey(todo.id),
                        todo: todo,
                        onToggle: () =>
                            ref.read(todoListProvider.notifier).toggle(todo.id),
                        onDelete: () =>
                            ref.read(todoListProvider.notifier).remove(todo.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(todoListProvider.notifier).add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}
