import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/api_client.dart';
import 'package:week4_api/data/comment_providers.dart';
import 'package:week4_api/data/models/comment.dart';
import 'package:week4_api/data/network_errors.dart';
import 'package:week4_api/data/repositories/comment_repository.dart';

// Adapter palsu tetap melewati parsing dan validasi HTTP Dio yang asli.
class StubAdapter implements HttpClientAdapter {
  String body = '[]';
  int status = 200;
  DioExceptionType? failure;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (failure != null) {
      throw DioException(requestOptions: options, type: failure!);
    }
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late StubAdapter adapter;
  late CommentRepository repository;

  setUp(() {
    dio = createDio();
    dio.interceptors.clear();
    adapter = StubAdapter();
    dio.httpClientAdapter = adapter;
    repository = CommentRepository(dio);
  });
  tearDown(() => dio.close(force: true));

  test('GET memakai postId dan konfigurasi client 10 detik', () async {
    adapter.body = '[{"postId":7,"id":3,"body":"Halo"}]';
    final result = await repository.fetchComments(7);
    final request = adapter.lastRequest!;
    expect(request.method, 'GET');
    expect(
      request.uri.toString(),
      'https://jsonplaceholder.typicode.com/comments?postId=7',
    );
    expect(request.connectTimeout, const Duration(seconds: 10));
    expect(request.receiveTimeout, const Duration(seconds: 10));
    expect(request.sendTimeout, const Duration(seconds: 10));
    expect(result.single.body, 'Halo');
    expect(result.single.postId, 7);
  });

  test('array kosong adalah hasil valid', () async {
    expect(await repository.fetchComments(1), isEmpty);
  });

  for (final body in ['null', '{}', '[null]', '[42]']) {
    test('respons rusak $body tidak disembunyikan sebagai daftar kosong', () {
      adapter.body = body;
      expect(repository.fetchComments(1), throwsFormatException);
    });
  }

  // Setiap jenis exception diuji sampai state AsyncError, bukan hanya helper.
  for (final type in DioExceptionType.values) {
    test('$type diteruskan repository ke AsyncError', () async {
      adapter.failure = type;
      final container = ProviderContainer(
        overrides: [commentRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final provider = commentsProvider(1);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await expectLater(
        container.read(provider.future),
        throwsA(isA<DioException>().having((e) => e.type, 'type', type)),
      );
      expect(container.read(provider), isA<AsyncError<List<Comment>>>());
    });
  }

  for (final code in [404, 500]) {
    test('HTTP $code menjadi AsyncError dan pesan yang sesuai', () async {
      adapter.status = code;
      final container = ProviderContainer(
        overrides: [commentRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final provider = commentsProvider(1);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);
      await expectLater(
        container.read(provider.future),
        throwsA(isA<DioException>()),
      );
      final state = container.read(provider);
      expect(state, isA<AsyncError<List<Comment>>>());
      expect(
        friendlyErrorMessage(state.error!),
        code == 404
            ? 'Data tidak ditemukan (404).'
            : 'Server bermasalah (500). Coba lagi nanti.',
      );
    });
  }

  test('family mengambil data sesuai ID tanpa berbagi state', () async {
    final container = ProviderContainer(
      overrides: [commentRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final first = container.listen(commentsProvider(1), (_, _) {});
    final second = container.listen(commentsProvider(2), (_, _) {});
    addTearDown(first.close);
    addTearDown(second.close);
    await container.read(commentsProvider(1).future);
    await container.read(commentsProvider(2).future);
    expect(
      container.read(commentsProvider(1)),
      isA<AsyncData<List<Comment>>>(),
    );
    expect(
      container.read(commentsProvider(2)),
      isA<AsyncData<List<Comment>>>(),
    );
    expect(adapter.lastRequest!.queryParameters['postId'], 2);
  });
}
