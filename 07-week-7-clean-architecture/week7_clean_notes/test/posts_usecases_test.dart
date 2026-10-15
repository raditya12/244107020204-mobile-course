import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/posts/domain/entities/post.dart';
import 'package:week7_clean_notes/features/posts/domain/usecases/load_posts.dart';
import 'package:week7_clean_notes/features/posts/domain/usecases/refresh_posts.dart';

import 'helpers/fakes.dart';

void main() {
  test('LoadPosts menampilkan cache lebih dahulu lalu refresh', () async {
    final repo = FakePostRepository(
      cached: [const Post(id: 1, title: 'Cache lama', body: 'tersedia')],
      remote: [const Post(id: 2, title: 'Baru', body: 'dari API')],
    );
    var refreshed = false;

    final cached = await LoadPosts(repo).call(
      offline: false,
      refresh: () async {
        await RefreshPosts(repo).call(canRefresh: () => true);
        refreshed = true;
      },
    );

    expect(cached.single.title, 'Cache lama');
    await Future<void>.delayed(Duration.zero);
    expect(refreshed, isTrue);
    expect(repo.saved!.single.title, 'Baru');
  });

  test('LoadPosts mode offline tidak menjadwalkan API', () async {
    final repo = FakePostRepository(
      cached: [const Post(id: 1, title: 'Cache lama', body: 'tersedia')],
    );
    var refreshes = 0;

    final cached = await LoadPosts(repo).call(
      offline: true,
      refresh: () async => refreshes++,
    );
    await Future<void>.delayed(Duration.zero);

    expect(cached.single.title, 'Cache lama');
    expect(refreshes, 0);
    expect(repo.remoteRequests, 0);
  });

  test('RefreshPosts meneruskan failure jaringan tanpa melempar', () async {
    final repo = FakePostRepository(
      remoteFailure: const NetworkFailure('offline'),
    );
    final result = await RefreshPosts(repo).call(canRefresh: () => true);
    expect(result.failure, isA<NetworkFailure>());
    expect(result.posts, isNull);
  });
}
