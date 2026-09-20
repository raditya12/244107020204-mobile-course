import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget menyediakan WidgetRef tanpa perlu state lokal halaman.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch membangun ulang UI setiap kali status pengambilan data berubah.
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: stats.when(
        // Tampilkan spinner juga ketika provider sedang dimuat ulang.
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator()),
        // Error ditampilkan bersama aksi untuk memulai permintaan baru.
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(statsProvider),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        ),
        // Data sukses dirender sebagai ListView dengan tiga baris statistik.
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.label),
              trailing: Text('${item.value}'),
            );
          },
        ),
      ),
    );
  }
}
