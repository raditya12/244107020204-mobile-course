import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/repositories/post_repository.dart';
import 'package:week5_offline_notes/local/note.dart';
import 'package:week5_offline_notes/main.dart';

class EmptyNotes extends NoteRepository {
  @override
  Future<List<Note>> fetchNotes() async => [];
  @override
  Future<int> countDirty() async => 0;
}

class EmptyPosts extends PostRepository {
  @override
  Future<List<Post>> readCachedPosts() async => [];
  @override
  Future<List<Post>> fetchRemotePosts() async => [];
  @override
  Future<void> saveCachedPosts(List<Post> posts) async {}
}

void main() {
  testWidgets('UI kosong dan toggle offline tidak menghalangi tambah catatan', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(EmptyNotes()),
          postRepositoryProvider.overrideWithValue(EmptyPosts()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Belum tersinkron: 0'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(find.text('Mode offline aktif'), findsOneWidget);
    await tester.tap(find.text('Tambah catatan'));
    await tester.pumpAndSettle();
    expect(find.text('Simpan'), findsOneWidget);
  });
}
