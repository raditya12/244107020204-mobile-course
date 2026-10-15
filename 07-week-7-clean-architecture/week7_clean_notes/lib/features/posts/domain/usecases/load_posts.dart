import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case: memuat bacaan dengan strategi cache-first.
///
/// Cache ditampilkan lebih dahulu; refresh jaringan dijadwalkan pada event
/// berikutnya (kecuali sedang offline). Logika ini tidak boleh berada di
/// widget.
class LoadPosts {
  const LoadPosts(this._repository);

  final PostRepository _repository;

  Future<List<Post>> call({
    required bool offline,
    required Future<void> Function() refresh,
  }) async {
    final cached = await _repository.readCachedPosts();
    if (!offline) {
      Future<void>(refresh);
    }
    return cached.posts;
  }
}
