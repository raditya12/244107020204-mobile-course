import '../../../../core/failures.dart';
import '../entities/post.dart';

/// Kontrak repository bacaan: cache lokal + sumber jaringan.
abstract class PostRepository {
  Future<({List<Post> posts, Failure? failure})> readCachedPosts();

  Future<({List<Post> posts, Failure? failure})> fetchRemotePosts();

  Future<({bool ok, Failure? failure})> saveCachedPosts(List<Post> posts);
}
