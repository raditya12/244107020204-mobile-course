import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/comment_providers.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';
import 'package:week4_api/pages/comments_page.dart';

// Fake repository membuat pengujian UI deterministik tanpa jaringan.
class RetryRepository extends CommentRepository {
  RetryRepository(super.dio);
  int calls = 0;

  @override
  Future<List<Comment>> fetchComments(int postId) async {
    if (++calls == 1) {
      throw DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      );
    }
    return [];
  }
}

void main() {
  testWidgets('UI menampilkan error lalu retry berhasil', (tester) async {
    final dio = Dio();
    addTearDown(() => dio.close(force: true));
    final repository = RetryRepository(dio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [commentRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: CommentsPage(postId: 1)),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak dapat terhubung ke server. Periksa internet Anda.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada komentar.'), findsOneWidget);
    expect(repository.calls, 2);
  });
}
