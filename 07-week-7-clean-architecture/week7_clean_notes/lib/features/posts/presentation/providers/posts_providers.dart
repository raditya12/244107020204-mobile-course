import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../infrastructure/database/db.dart';
import '../../data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/load_posts.dart';
import '../../domain/usecases/refresh_posts.dart';

/// Wiring DI fitur `posts`.
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(openDb: openNotesDb);
});

final loadPostsProvider = Provider<LoadPosts>(
  (ref) => LoadPosts(ref.watch(postRepositoryProvider)),
);

final refreshPostsProvider = Provider<RefreshPosts>(
  (ref) => RefreshPosts(ref.watch(postRepositoryProvider)),
);

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  bool _refreshing = false;
  String? refreshError;

  @override
  Future<List<Post>> build() {
    final offline = ref.watch(forceOfflineProvider);
    return ref.watch(loadPostsProvider).call(
      offline: offline,
      refresh: () async {
        if (ref.mounted) await refresh();
      },
    );
  }

  Future<void> refresh() async {
    if (_refreshing || ref.read(forceOfflineProvider)) return;
    _refreshing = true;
    refreshError = null;
    try {
      final result = await ref.read(refreshPostsProvider).call(
        canRefresh: () => ref.mounted && !ref.read(forceOfflineProvider),
      );
      if (result.failure != null) {
        if (ref.mounted) {
          refreshError = 'Jaringan gagal. Cache lokal tetap tersedia.';
          state = AsyncData(state.value ?? []);
        }
        return;
      }
      if (ref.mounted && result.posts != null) {
        state = AsyncData(result.posts!);
      }
    } finally {
      _refreshing = false;
    }
  }
}
