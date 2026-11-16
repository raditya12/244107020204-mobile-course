import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/rebuild_stats.dart';
import '../providers/notes_providers.dart';

/// Kartu mode offline + sinkronisasi.
///
/// Diekstrak dari halaman utama: hanya widget kecil ini yang me-watch
/// [forceOfflineProvider], sehingga toggle offline tidak me-rebuild
/// daftar catatan dan daftar bacaan (optimasi rebuild Week 11).
class OfflineCard extends ConsumerWidget {
  const OfflineCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    RebuildStats.count('OfflineCard');
    final offline = ref.watch(forceOfflineProvider);
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: Text(offline ? 'Mode offline aktif' : 'Mode online'),
            subtitle: const Text(
              'forceOffline: blokir jaringan, data lokal tetap tersedia',
            ),
            secondary: Icon(offline ? Icons.cloud_off : Icons.cloud_done),
            value: offline,
            onChanged: (value) =>
                ref.read(forceOfflineProvider.notifier).setOffline(value),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // select: hanya rebuild saat angka berubah, bukan saat
                // AsyncValue berganti identitas (mis. setelah invalidasi).
                Consumer(
                  builder: (_, ref, _) {
                    final dirty = ref.watch(
                      dirtyCountProvider.select((async) => async.value ?? 0),
                    );
                    return Chip(
                      avatar: const Icon(Icons.schedule, size: 18),
                      label: Text('Belum tersinkron: $dirty'),
                    );
                  },
                ),
                // select isLoading: tombol tidak ikut rebuild saat hasil
                // sinkronisasi (angka) tiba.
                Consumer(
                  builder: (_, ref, _) {
                    final loading = ref.watch(
                      syncProvider.select((state) => state.isLoading),
                    );
                    return FilledButton.icon(
                      onPressed: offline || loading
                          ? null
                          : () async {
                              await ref
                                  .read(syncProvider.notifier)
                                  .synchronize();
                            },
                      icon: const Icon(Icons.sync),
                      label: Text(
                        loading ? 'Mengirim antrean...' : 'Sinkronkan',
                      ),
                    );
                  },
                ),
                const Text('Server upload: simulasi delay 1 detik/catatan'),
              ],
            ),
          ),
          Consumer(
            builder: (_, ref, _) {
              final sync = ref.watch(syncProvider);
              return Column(
                children: [
                  if (sync.hasError)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${sync.error}'),
                    ),
                  if (sync.value != null && sync.value! > 0 && !sync.isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        '${sync.value} catatan berhasil disinkronkan',
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
