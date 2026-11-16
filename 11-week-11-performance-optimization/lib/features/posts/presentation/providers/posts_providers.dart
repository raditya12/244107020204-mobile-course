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

/// Jumlah bacaan yang tampil saat ini (pagination infinite scroll).
///
/// Bertambah 10 per halaman saat pengguna scroll mendekati bawah daftar.
final postsPaginationProvider = NotifierProvider<PostsPaginationNotifier, int>(
  PostsPaginationNotifier.new,
);

class PostsPaginationNotifier extends Notifier<int> {
  static const int pageSize = 10;

  @override
  int build() => pageSize;

  /// Menambah satu halaman bacaan; berhenti saat semua sudah tampil.
  void loadMore(int total) {
    if (state < total) {
      state = (state + pageSize).clamp(0, total);
    }
  }
}

/// Pesan kegagalan refresh terakhir (bukan kegagalan cache).
///
/// Dipisah dari field notifier agar UI bereaksi secara reaktif tanpa
/// mengubah tipe state [postsProvider].
final refreshErrorProvider = NotifierProvider<RefreshErrorNotifier, String?>(
  RefreshErrorNotifier.new,
);

class RefreshErrorNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? message) => state = message;
}

class PostsNotifier extends AsyncNotifier<List<Post>> {
  bool _refreshing = false;

  @override
  Future<List<Post>> build() {
    // Dibaca (read) sekali per build, tidak di-watch: toggle mode offline
    // tidak perlu me-reload seluruh daftar bacaan dari cache. Saat kembali
    // online, pengguna memakai tombol refresh yang tersedia.
    final offline = ref.read(forceOfflineProvider);
    return ref
        .watch(loadPostsProvider)
        .call(
          offline: offline,
          refresh: () async {
            if (ref.mounted) await refresh();
          },
        );
  }

  Future<void> refresh() async {
    if (_refreshing || ref.read(forceOfflineProvider)) return;
    _refreshing = true;
    ref.read(refreshErrorProvider.notifier).set(null);
    try {
      final result = await ref
          .read(refreshPostsProvider)
          .call(
            canRefresh: () => ref.mounted && !ref.read(forceOfflineProvider),
          );
      if (result.failure != null) {
        if (ref.mounted) {
          ref
              .read(refreshErrorProvider.notifier)
              .set('Jaringan gagal. Cache lokal tetap tersedia.');
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
