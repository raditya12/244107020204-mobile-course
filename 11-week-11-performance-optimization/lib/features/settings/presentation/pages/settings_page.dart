import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final value = _apiKeyController.text.trim();
    if (value.isEmpty) return;
    await ref.read(prefsRepositoryProvider).setApiKey(value);
    _apiKeyController.clear();
    if (mounted) ref.invalidate(apiKeyProvider);
  }

  @override
  Widget build(BuildContext context) {
    final dark = ref.watch(darkModeProvider);
    final apiKey = ref.watch(apiKeyProvider).value;
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
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('API key asisten AI'),
            subtitle: Text(
              (apiKey == null || apiKey.isEmpty)
                  ? 'Belum diatur. Key disimpan lokal di perangkat ini.'
                  : 'Tersimpan: ${apiKey.substring(0, apiKey.length.clamp(0, 6))}...',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('api-key-input'),
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'API key Gemini',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  key: const Key('api-key-save'),
                  tooltip: 'Simpan API key',
                  onPressed: _saveApiKey,
                  icon: const Icon(Icons.save),
                ),
              ],
            ),
          ),
          const ListTile(
            leading: Icon(Icons.storage),
            title: Text('Penyimpanan lokal'),
            subtitle: Text(
              'SQLite: catatan dan cache bacaan. SharedPreferences: tema, waktu buka, dan API key.',
            ),
          ),
        ],
      ),
    );
  }
}
