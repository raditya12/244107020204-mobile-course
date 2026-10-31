import 'package:flutter/material.dart';

import '../data/announcement.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final announcement = findAnnouncement(id);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: announcement == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Pengumuman dengan id "$id" tidak ditemukan.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  announcement.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text('id: ${announcement.id}'),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(height: 16),
                Text(
                  announcement.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.link),
                    title: const Text('Dibuka dari deep link FCM'),
                    subtitle: Text('/pengumuman/${announcement.id}'),
                  ),
                ),
              ],
            ),
    );
  }
}
