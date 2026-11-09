import '../../../../core/failures.dart';
import '../entities/post.dart';
import '../repositories/post_repository.dart';

/// Use case: mengambil bacaan terbaru dari API lalu menyimpannya ke cache.
class RefreshPosts {
  const RefreshPosts(this._repository);

  final PostRepository _repository;

  Future<({List<Post>? posts, Failure? failure})> call({
    required bool Function() canRefresh,
  }) async {
    if (!canRefresh()) return (posts: null, failure: null);
    final remote = await _repository.fetchRemotePosts();
    if (remote.failure != null) {
      return (posts: null, failure: remote.failure);
    }
    if (!canRefresh()) return (posts: null, failure: null);
    final saved = await _repository.saveCachedPosts(remote.posts);
    if (saved.failure != null) {
      return (posts: null, failure: saved.failure);
    }
    return (posts: remote.posts, failure: null);
  }
}
