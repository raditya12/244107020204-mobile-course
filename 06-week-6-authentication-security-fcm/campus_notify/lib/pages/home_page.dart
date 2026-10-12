import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/announcement.dart';
import '../messaging/push_service.dart';
import '../messaging/token_preview.dart';
import '../providers/app_providers.dart';
import '../providers/auth_provider.dart';
import '../routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final push = ref.watch(pushServiceProvider);
    final firebaseReady = ref.watch(firebaseReadyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SessionCard(),
          const SizedBox(height: 12),
          _PushCard(push: push, firebaseReady: firebaseReady),
          const SizedBox(height: 12),
          _DebugCard(push: push),
          const SizedBox(height: 12),
          Text(
            'Pengumuman',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final announcement in sampleAnnouncements)
            Card(
              child: ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: Text(announcement.title),
                subtitle: Text('Buka /pengumuman/${announcement.id}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.go(Routes.announcementFor(announcement.id)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(tokenStoreProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<String?>>(
          future: Future.wait([store.readEmail(), store.readAccess()]),
          builder: (context, snapshot) {
            final email = snapshot.data?[0] ?? 'mahasiswa';
            final access = snapshot.data?[1];
            final accessPreview = access == null
                ? '-'
                : previewToken(access);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'Sesi aktif',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Pengguna: $email'),
                Text('Access token: $accessPreview'),
                const SizedBox(height: 4),
                Text(
                  'Token disimpan di flutter_secure_storage, bukan '
                  'SharedPreferences.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PushCard extends StatelessWidget {
  const _PushCard({required this.push, required this.firebaseReady});

  final PushService push;
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined),
                const SizedBox(width: 8),
                Text(
                  'Firebase Cloud Messaging',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              firebaseReady
                  ? 'Firebase aktif.'
                  : 'Firebase belum dikonfigurasi (google-services.json belum '
                      'dipasang). Aplikasi berjalan dalam mode demo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Token FCM: '),
                ValueListenableBuilder<String?>(
                  valueListenable: push.tokenPreview,
                  builder: (context, value, _) => Text(
                    value ?? 'belum tersedia',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Token ditampilkan terpotong (12 karakter pertama).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Topik pengumuman-kampus: '),
                ValueListenableBuilder<bool>(
                  valueListenable: push.subscribed,
                  builder: (context, value, _) => Chip(
                    label: Text(value ? 'berlangganan' : 'tidak'),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: push.subscribeToAnnouncements,
                  child: const Text('Subscribe'),
                ),
                OutlinedButton(
                  onPressed: push.unsubscribeFromAnnouncements,
                  child: const Text('Unsubscribe'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugCard extends ConsumerWidget {
  const _DebugCard({required this.push});

  final PushService push;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report_outlined),
                const SizedBox(width: 8),
                Text(
                  'Debug notifikasi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tombol di bawah memakai handler yang sama dengan FCM, sehingga '
              'alur foreground dan deep link dapat diuji tanpa backend.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => push.showLocalNotification(
                    title: 'Jadwal kuliah berubah',
                    body: 'Kelas Mobile pindah ke Ruang A2 jam 13.00',
                    route: Routes.announcementFor('3'),
                  ),
                  child: const Text('Simulasi foreground'),
                ),
                OutlinedButton(
                  onPressed: () =>
                      context.go(Routes.announcementFor('3')),
                  child: const Text('Simulasi klik deep link'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String?>(
              valueListenable: push.lastEvent,
              builder: (context, value, _) => Text(
                'Event terakhir: ${value ?? '-'}',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Platform: ${defaultTargetPlatform.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
