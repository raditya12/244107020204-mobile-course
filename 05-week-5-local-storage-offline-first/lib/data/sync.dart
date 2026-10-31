import 'dart:async';

import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';

Future<List<Post>> loadPostsCacheFirst(
  PostRepository repo, {
  required bool offline,
  required Future<void> Function() refresh,
}) async {
  final cached = await repo.readCachedPosts();
  // Publikasikan cache sebelum mulai refresh pada event berikutnya.
  if (!offline) unawaited(Future<void>(refresh));
  return cached;
}

Future<List<Post>?> refreshPostsInBackground(
  PostRepository repo, {
  required bool Function() canRefresh,
}) async {
  if (!canRefresh()) return null;
  final posts = await repo.fetchRemotePosts();
  if (!canRefresh()) return null;
  await repo.saveCachedPosts(posts);
  return posts;
}

Future<int> syncNotes(
  NoteRepository repo, {
  required bool Function() isOffline,
  Future<void> Function()? upload,
}) async {
  if (isOffline()) {
    throw StateError('Mode offline aktif. Sinkronisasi ditunda.');
  }
  final dirty = (await repo.fetchNotes()).where((note) => note.dirty).toList()
    ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
  for (final note in dirty) {
    if (isOffline()) {
      throw StateError('Koneksi dinonaktifkan. Antrean tetap disimpan.');
    }
    await (upload?.call() ?? Future<void>.delayed(const Duration(seconds: 1)));
    if (isOffline()) throw StateError('Koneksi dinonaktifkan saat upload.');
    await repo.markSynced(note);
  }
  return dirty.length;
}
