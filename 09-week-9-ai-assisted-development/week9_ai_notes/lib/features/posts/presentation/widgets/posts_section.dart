import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../providers/posts_providers.dart';

/// Bagian UI bacaan API (cache-first). Hanya membaca state provider, tanpa
/// SQL, Dio, atau JSON.
class PostsSection extends ConsumerWidget {
  const PostsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(forceOfflineProvider);
    final posts = ref.watch(postsProvider);
    final refreshError = ref.read(postsProvider.notifier).refreshError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        if (refreshError != null) Text(refreshError),
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
    );
  }
}
