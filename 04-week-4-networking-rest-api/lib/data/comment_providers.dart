import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/comment.dart';
import 'providers.dart';
import 'repositories/comment_repository.dart';

/// Dependency injection: UI tidak perlu mengetahui Dio.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Family memisahkan state komentar untuk setiap postId.
final commentsProvider = AsyncNotifierProvider.autoDispose
    .family<CommentsNotifier, List<Comment>, int>(
      CommentsNotifier.new,
      // Error langsung terlihat; pengguna dapat mencoba ulang melalui UI.
      retry: (retryCount, error) => null,
    );

class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  CommentsNotifier(this.postId);
  final int postId;

  @override
  Future<List<Comment>> build() {
    // Riverpod mengubah Future menjadi AsyncLoading, AsyncData, atau AsyncError.
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}
