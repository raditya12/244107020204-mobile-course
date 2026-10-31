import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../local/note.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, [Note? note]) async {
    final title = TextEditingController(text: note?.title);
    final body = TextEditingController(text: note?.body);
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Tambah catatan' : 'Edit catatan'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Judul'),
                autofocus: true,
              ),
              TextField(
                controller: body,
                decoration: const InputDecoration(labelText: 'Isi catatan'),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (title.text.trim().isNotEmpty) Navigator.pop(context, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (save == true) {
      try {
        final repo = ref.read(noteRepositoryProvider);
        if (note == null) {
          await repo.addNote(title: title.text.trim(), body: body.text.trim());
        } else {
          await repo.updateNote(
            note.id!,
            title: title.text.trim(),
            body: body.text.trim(),
          );
        }
        ref.invalidate(notesProvider);
        ref.invalidate(dirtyCountProvider);
        if (note != null) ref.invalidate(noteDetailProvider(note.id!));
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyimpan catatan. Coba lagi.'),
            ),
          );
        }
      }
    }
    // Dialog sudah menyelesaikan animasi sebelum controller dilepas.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    title.dispose();
    body.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(forceOfflineProvider);
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;
    final sync = ref.watch(syncProvider);
    final posts = ref.watch(postsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Local Storage & Offline First',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Text(
                'Praktikum 1–3 • SharedPreferences + SQLite + Riverpod',
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        offline ? 'Mode offline aktif' : 'Mode online',
                      ),
                      subtitle: const Text(
                        'forceOffline: blokir jaringan, data lokal tetap tersedia',
                      ),
                      secondary: Icon(
                        offline ? Icons.cloud_off : Icons.cloud_done,
                      ),
                      value: offline,
                      onChanged: (value) => ref
                          .read(forceOfflineProvider.notifier)
                          .setOffline(value),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.schedule, size: 18),
                            label: Text('Belum tersinkron: $dirty'),
                          ),
                          FilledButton.icon(
                            onPressed: offline || sync.isLoading
                                ? null
                                : () async {
                                    await ref
                                        .read(syncProvider.notifier)
                                        .synchronize();
                                  },
                            icon: const Icon(Icons.sync),
                            label: Text(
                              sync.isLoading
                                  ? 'Mengirim antrean...'
                                  : 'Sinkronkan',
                            ),
                          ),
                          const Text(
                            'Server upload: simulasi delay 1 detik/catatan',
                          ),
                        ],
                      ),
                    ),
                    if (sync.hasError)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('${sync.error}'),
                      ),
                    if (sync.value != null &&
                        sync.value! > 0 &&
                        !sync.isLoading)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '${sync.value} catatan berhasil disinkronkan',
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Catatan lokal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  FilledButton.icon(
                    onPressed: () => _edit(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah catatan'),
                  ),
                ],
              ),
              notes.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => ListTile(
                  title: const Text('Gagal membaca database.'),
                  trailing: TextButton(
                    onPressed: () => ref.invalidate(notesProvider),
                    child: const Text('Coba lagi'),
                  ),
                ),
                data: (items) => items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Belum ada catatan. Tambahkan catatan, bahkan saat offline.',
                        ),
                      )
                    : Column(
                        children: items
                            .map(
                              (note) => NoteTile(
                                note: note,
                                onOpen: () => context.go('/note/${note.id}'),
                                onEdit: () => _edit(context, ref, note),
                                onDelete: () async {
                                  try {
                                    await ref
                                        .read(noteRepositoryProvider)
                                        .deleteNote(note.id!);
                                    ref.invalidate(notesProvider);
                                    ref.invalidate(dirtyCountProvider);
                                    ref.invalidate(
                                      noteDetailProvider(note.id!),
                                    );
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Gagal menghapus catatan.',
                                              ),
                                            ),
                                          );
                                    }
                                  }
                                },
                              ),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bacaan API • cache-first',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    tooltip: 'Refresh bacaan',
                    onPressed: offline
                        ? null
                        : () => ref.read(postsProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              Text(
                offline
                    ? 'Sumber: cache SQLite • tidak ada request jaringan'
                    : 'Cache lokal tampil dahulu; API direfresh di background.',
              ),
              if (ref.read(postsProvider.notifier).refreshError != null)
                Text(ref.read(postsProvider.notifier).refreshError!),
              posts.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text('Gagal membaca cache.'),
                data: (items) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${items.length} bacaan tersimpan di cache'),
                    if (items.isEmpty)
                      const Text(
                        'Cache kosong. Hubungkan jaringan untuk mengambil bacaan.',
                      ),
                    ...items
                        .take(5)
                        .map(
                          (post) => Card(
                            child: ListTile(
                              leading: CircleAvatar(child: Text('${post.id}')),
                              title: Text(post.title),
                              subtitle: Text(
                                post.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
