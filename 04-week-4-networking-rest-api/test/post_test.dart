import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/paged_posts.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/pages/post_detail_page.dart';
import 'package:week4_api/widgets/post_tile.dart';

const sample = Post(
  userId: 1,
  id: 1,
  title: 'Judul lengkap',
  body: 'Isi lengkap',
);

class FakePostRepository extends PostRepository {
  FakePostRepository(super.dio);
  bool fail = false;
  int detailCalls = 0;
  final pages = <int>[];
  Completer<List<Post>>? pendingPage;
  @override
  Future<List<Post>> fetchPosts() async {
    if (fail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return [sample];
  }

  @override
  Future<Post> fetchPost(int id) async {
    detailCalls++;
    return (await fetchPosts()).single;
  }

  @override
  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    pages.add(page);
    if (pendingPage != null) return pendingPage!.future;
    await fetchPosts();
    return page == 1
        ? List.generate(
            10,
            (i) => Post(userId: 1, id: i + 1, title: 'Post $i', body: 'Isi'),
          )
        : [];
  }
}

void main() {
  late Dio dio;
  late FakePostRepository repository;
  late ProviderContainer container;
  setUp(() {
    dio = Dio();
    repository = FakePostRepository(dio);
    container = ProviderContainer(
      overrides: [postRepositoryProvider.overrideWithValue(repository)],
    );
  });
  tearDown(() {
    container.dispose();
    dio.close(force: true);
  });

  test('fromJson aman terhadap field yang hilang dan null', () {
    final post = Post.fromJson({'id': 7, 'title': null});
    expect(post.id, 7);
    expect(post.userId, 0);
    expect(post.title, '');
    expect(post.body, '');
  });
  test('mapping error koneksi', () {
    expect(
      friendlyErrorMessage(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      ),
      contains('terhubung'),
    );
  });
  test('provider sukses dengan repository palsu', () async {
    expect((await readPostsOnce(container)).single.title, sample.title);
  });
  test('provider error dengan repository palsu', () async {
    repository.fail = true;
    final error = await readPostsErrorOnce(container);
    expect(error, isA<DioException>());
    expect(friendlyErrorMessage(error!), contains('terhubung'));
  });
  test(
    'pagination guard, error mempertahankan data, retry dan akhir data',
    () async {
      container.read(pagedPostsProvider);
      await Future<void>.delayed(Duration.zero);
      final notifier = container.read(pagedPostsProvider.notifier);
      expect(container.read(pagedPostsProvider).items.length, 10);
      repository.pendingPage = Completer<List<Post>>();
      final pending = notifier.loadNextPage();
      await notifier.loadNextPage();
      expect(repository.pages, [1, 2]);
      repository.pendingPage!.completeError(StateError('offline'));
      await pending;
      expect(container.read(pagedPostsProvider).items.length, 10);
      expect(container.read(pagedPostsProvider).page, 1);
      expect(container.read(pagedPostsProvider).error, isA<StateError>());
      repository.pendingPage = null;
      await notifier.loadNextPage();
      expect(repository.pages, [1, 2, 2]);
      expect(container.read(pagedPostsProvider).hasMore, false);
      await notifier.loadNextPage();
      expect(repository.pages, [1, 2, 2]);
    },
  );
  test('request halaman pertama tidak ganda saat scroll/retry', () async {
    repository.pendingPage = Completer<List<Post>>();
    container.read(pagedPostsProvider);
    await Future<void>.delayed(Duration.zero);
    final notifier = container.read(pagedPostsProvider.notifier);
    await notifier.loadFirstPage();
    await notifier.loadNextPage();
    expect(repository.pages, [1]);
    repository.pendingPage!.complete([]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(pagedPostsProvider).hasMore, false);
  });

  testWidgets('PostTile membuka /post/:id dengan data list tanpa HTTP', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: PostTile(post: sample)),
        ),
        GoRoute(
          path: '/post/:id',
          builder: (_, state) => PostDetailPage(
            id: int.parse(state.pathParameters['id']!),
            loadedPost: state.extra as Post,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text(sample.title));
    await tester.pumpAndSettle();
    expect(
      GoRouterState.of(tester.element(find.byType(PostDetailPage))).uri.path,
      '/post/1',
    );
    expect(find.text(sample.body), findsOneWidget);
    expect(repository.detailCalls, 0);
  });
  testWidgets('deep link detail mengambil repository dan retry ketika error', (
    tester,
  ) async {
    repository.fail = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [postRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: PostDetailPage(id: 1)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text(sample.title), findsOneWidget);
    expect(find.text(sample.body), findsOneWidget);
    expect(repository.detailCalls, 2);
  });
}
