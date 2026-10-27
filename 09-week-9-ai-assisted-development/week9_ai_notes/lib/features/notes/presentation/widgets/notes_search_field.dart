import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_providers.dart';

class NotesSearchField extends ConsumerStatefulWidget {
  const NotesSearchField({super.key});

  @override
  ConsumerState<NotesSearchField> createState() => _NotesSearchFieldState();
}

class _NotesSearchFieldState extends ConsumerState<NotesSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(searchQueryProvider, (previous, next) {
      if (_controller.text != next) {
        _controller.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    });
    final query = ref.watch(searchQueryProvider);
    return TextField(
      key: const Key('notes-search-field'),
      controller: _controller,
      onChanged: (value) =>
          ref.read(searchQueryProvider.notifier).update(value),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari judul catatan',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                onPressed: () =>
                    ref.read(searchQueryProvider.notifier).update(''),
                icon: const Icon(Icons.clear),
              ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
