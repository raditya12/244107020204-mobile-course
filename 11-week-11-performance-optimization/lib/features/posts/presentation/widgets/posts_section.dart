import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/rebuild_stats.dart';
import '../../domain/entities/post.dart';
import '../providers/posts_providers.dart';

/// Header bagian bacaan API: judul, tombol refresh, status sumber, jumlah
/// cache, dan pesan kegagalan refresh terakhir.
///
/// Dipisah dari daftar bacaan agar toggle mode offline hanya me-rebuild
/// widget kecil ini, bukan seluruh daftar (lihat docs/performance-report.md).
class PostsHeader extends ConsumerWidget {
  const PostsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    RebuildStats.count('PostsHeader');
    final offline = ref.watch(forceOfflineProvider);
    final refreshError = ref.watch(refreshErrorProvider);
    final count = ref.watch(postsProvider).value?.length;
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
        if (count != null) Text('$count bacaan tersimpan di cache'),
      ],
    );
  }
}

/// Satu tile bacaan. Const constructor + [RepaintBoundary] agar paint tiap
/// tile terisolasi dan instance const tidak ikut rebuild parent.
class PostTile extends StatelessWidget {
  const PostTile({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    RebuildStats.count('PostTile');
    return RepaintBoundary(
      child: Card(
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
    );
  }
}
