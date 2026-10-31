import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/note.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'sync.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());
final postRepositoryProvider = Provider((ref) => PostRepository());
final notesProvider = FutureProvider<List<Note>>(
  (ref) => ref.watch(noteRepositoryProvider).fetchNotes(),
  retry: (_, _) => null,
);
final noteDetailProvider = FutureProvider.family<Note?, int>(
  (ref, id) => ref.watch(noteRepositoryProvider).fetchNote(id),
  retry: (_, _) => null,
);
final dirtyCountProvider = FutureProvider<int>(
  (ref) => ref.watch(noteRepositoryProvider).countDirty(),
);
final forceOfflineProvider = NotifierProvider<OfflineNotifier, bool>(
  OfflineNotifier.new,
);

class OfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void setOffline(bool value) => state = value;
}

final syncProvider = AsyncNotifierProvider<SyncNotifier, int>(SyncNotifier.new);

class SyncNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => 0;
  Future<void> synchronize() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => syncNotes(
        ref.read(noteRepositoryProvider),
        isOffline: () => ref.read(forceOfflineProvider),
      ),
    );
    ref.invalidate(notesProvider);
    ref.invalidate(dirtyCountProvider);
    ref.invalidate(noteDetailProvider);
  }
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  bool _refreshing = false;
  String? refreshError;

  @override
  Future<List<Post>> build() {
    final offline = ref.watch(forceOfflineProvider);
    return loadPostsCacheFirst(
      ref.watch(postRepositoryProvider),
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
      final repo = ref.read(postRepositoryProvider);
      final posts = await refreshPostsInBackground(
        repo,
        canRefresh: () => ref.mounted && !ref.read(forceOfflineProvider),
      );
      if (ref.mounted && posts != null) state = AsyncData(posts);
    } catch (_) {
      if (ref.mounted) {
        refreshError = 'Jaringan gagal. Cache lokal tetap tersedia.';
        state = AsyncData(state.value ?? []);
      }
    } finally {
      _refreshing = false;
    }
  }
}
