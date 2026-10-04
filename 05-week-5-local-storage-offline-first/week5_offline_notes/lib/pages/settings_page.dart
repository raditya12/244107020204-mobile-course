import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/prefs.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());
final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(prefsRepositoryProvider);
  final previous = await repo.getLastOpened();
  await repo.markOpenedNow();
  return previous;
});

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
