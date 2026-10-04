import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('Detail catatan'),
      leading: IconButton(
        tooltip: 'Kembali ke catatan',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.canPop() ? context.pop() : context.go('/'),
      ),
    ),
    body: ref
        .watch(noteDetailProvider(id))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Gagal membaca catatan.'),
                TextButton(
                  onPressed: () => ref.invalidate(noteDetailProvider(id)),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
          data: (note) => note == null
              ? const Center(child: Text('Catatan tidak ditemukan.'))
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Text(
                          note.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          note.body,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Diperbarui: ${note.updatedAt.toLocal().toString().split('.').first}',
                        ),
                        const SizedBox(height: 8),
                        Text(note.dirty ? 'Belum tersinkron' : 'Tersinkron'),
                        const SizedBox(height: 16),
                        const Text(
                          'Catatan dibaca dari penyimpanan lokal dan tetap tersedia saat offline.',
                        ),
                      ],
                    ),
                  ),
                ),
        ),
  );
}
