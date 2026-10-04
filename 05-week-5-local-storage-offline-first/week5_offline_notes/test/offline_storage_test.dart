import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/repositories/post_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late NoteRepository repo;
  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute(
      'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'title TEXT NOT NULL, body TEXT NOT NULL, updated_at TEXT NOT NULL, dirty INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE cached_posts(id INTEGER PRIMARY KEY, payload TEXT NOT NULL, cached_at TEXT NOT NULL)',
    );
    repo = NoteRepository(openDb: () async => db);
  });
  tearDown(() => db.close());

  test('CRUD lokal dan antrean sync sebelum/sesudah online', () async {
    final note = await repo.addNote(title: 'Catatan offline');
    expect((await repo.fetchNote(note.id!))!.title, 'Catatan offline');
    expect(await repo.countDirty(), 1);
    await expectLater(syncNotes(repo, isOffline: () => true), throwsStateError);
    expect(await repo.countDirty(), 1);
    expect(
      await syncNotes(repo, isOffline: () => false, upload: () async {}),
      1,
    );
    expect(await repo.countDirty(), 0);
    await repo.updateNote(
      note.id!,
      title: 'Diedit offline',
      body: 'Tetap lokal',
    );
    expect((await repo.fetchNotes()).single.title, 'Diedit offline');
    expect(await repo.countDirty(), 1);
    await repo.deleteNote(note.id!);
    expect(await repo.fetchNote(note.id!), isNull);
    expect(await repo.fetchNotes(), isEmpty);
  });

  test('edit ketika upload berlangsung tidak ikut dibersihkan', () async {
    final note = await repo.addNote(title: 'Versi awal');
    await syncNotes(
      repo,
      isOffline: () => false,
      upload: () async {
        await repo.updateNote(
          note.id!,
          title: 'Versi baru',
          body: 'Belum dikirim',
        );
      },
    );
    expect(await repo.countDirty(), 1);
  });

  test('upload gagal mempertahankan dirty', () async {
    await repo.addNote(title: 'Antrean');
    await expectLater(
      syncNotes(
        repo,
        isOffline: () => false,
        upload: () async => throw Exception('Server gagal'),
      ),
      throwsException,
    );
    expect(await repo.countDirty(), 1);
  });

  test('cache bacaan bisa dibaca kembali tanpa API', () async {
    final posts = PostRepository(openDb: () async => db);
    await posts.saveCachedPosts([
      const Post(id: 1, title: 'Bacaan', body: 'Cache SQLite'),
    ]);
    expect((await posts.readCachedPosts()).single.body, 'Cache SQLite');
  });
}
