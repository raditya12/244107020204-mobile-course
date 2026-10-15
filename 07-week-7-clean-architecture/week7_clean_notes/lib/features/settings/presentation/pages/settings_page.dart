import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema gelap'),
            subtitle: const Text('Preferensi disimpan di SharedPreferences'),
            value: dark.value ?? false,
            onChanged: dark.isLoading
                ? null
                : (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          if (dark.hasError)
            const ListTile(title: Text('Gagal menyimpan tema. Coba lagi.')),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Terakhir dibuka (sesi sebelumnya)'),
            subtitle: Text(
              ref.watch(lastOpenedProvider).value ?? 'Ini adalah sesi pertama',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.storage),
            title: Text('Penyimpanan lokal'),
            subtitle: Text(
              'SQLite: catatan dan cache bacaan. SharedPreferences: tema dan waktu buka.',
            ),
          ),
        ],
      ),
    );
  }
}
