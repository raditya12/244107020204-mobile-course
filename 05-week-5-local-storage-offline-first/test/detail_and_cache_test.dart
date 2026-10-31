import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/repositories/post_repository.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/sync.dart';
import 'package:week5_offline_notes/local/note.dart';
import 'package:week5_offline_notes/main.dart';
import 'package:week5_offline_notes/router.dart';

class DetailOnlyRepository extends NoteRepository {
  int? requestedId;

  @override
  Future<List<Note>> fetchNotes() =>
      throw StateError('List tidak boleh dibaca');

  @override
  Future<Note?> fetchNote(int id) async {
    requestedId = id;
    return id == 7
        ? Note(
            id: 7,
            title: 'Dari database lokal',
            body: 'Isi tersimpan',
            updatedAt: DateTime.utc(2026),
          )
        : null;
  }
}

class CachedPostsRepository extends PostRepository {
  int requests = 0;
  final response = Completer<List<Post>>();
  List<Post>? saved;

  @override
  Future<List<Post>> readCachedPosts() async => [
    const Post(id: 1, title: 'Cache lama', body: 'Tetap tersedia'),
  ];

  @override
  Future<List<Post>> fetchRemotePosts() {
    requests++;
    return response.future;
  }

  @override
  Future<void> saveCachedPosts(List<Post> posts) async => saved = posts;
}

void main() {
  testWidgets('URL detail langsung membaca repository tanpa halaman list', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = DetailOnlyRepository();
    final container = ProviderContainer(
      overrides: [noteRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(routerProvider).go('/note/7');
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    expect(repo.requestedId, 7);
    expect(find.text('Dari database lokal'), findsOneWidget);
    expect(find.text('Isi tersimpan'), findsOneWidget);
    container.read(routerProvider).go('/note/999');
    await tester.pumpAndSettle();
    expect(find.text('Catatan tidak ditemukan.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  test(
    'cache tersedia sebelum respons API, refresh kemudian disimpan',
    () async {
      final repo = CachedPostsRepository();
      final refreshed = Completer<void>();
      final cached = await loadPostsCacheFirst(
        repo,
        offline: false,
        refresh: () async {
          await refreshPostsInBackground(repo, canRefresh: () => true);
          refreshed.complete();
        },
      );
      expect(cached.single.title, 'Cache lama');
      expect(repo.response.isCompleted, isFalse);
      repo.response.complete([
        const Post(id: 2, title: 'Baru', body: 'Dari API'),
      ]);
      await refreshed.future;
      expect(repo.requests, 1);
      expect(repo.saved!.single.title, 'Baru');
    },
  );

  test('mode offline membaca cache tanpa menjadwalkan API', () async {
    final repo = CachedPostsRepository();
    var refreshes = 0;
    final cached = await loadPostsCacheFirst(
      repo,
      offline: true,
      refresh: () async {
        refreshes++;
      },
    );
    await Future<void>.delayed(Duration.zero);
    expect(cached.single.title, 'Cache lama');
    expect(refreshes, 0);
    expect(repo.requests, 0);
  });
}
