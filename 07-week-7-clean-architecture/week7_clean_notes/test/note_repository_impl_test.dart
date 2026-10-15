import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/notes/data/repositories/note_repository_impl.dart';
import 'package:week7_clean_notes/features/notes/domain/usecases/sync_notes.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late NoteRepositoryImpl repo;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute(
      'CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'title TEXT NOT NULL, body TEXT NOT NULL, updated_at TEXT NOT NULL, dirty INTEGER NOT NULL)',
    );
    repo = NoteRepositoryImpl(openDb: () async => db);
  });

  tearDown(() => db.close());

  test('CRUD lokal mengembalikan entity dan menandai dirty', () async {
    final added = await repo.addNote(title: 'Catatan offline', body: 'isi');
    expect(added.failure, isNull);
    expect(added.note!.dirty, isTrue);

    final fetched = await repo.fetchNote(added.note!.id!);
    expect(fetched.note!.title, 'Catatan offline');
    expect(await repo.countDirty(), (count: 1, failure: null));

    final updated = await repo.updateNote(
      added.note!.id!,
      title: 'Diedit',
      body: 'tetap lokal',
    );
    expect(updated.note!.title, 'Diedit');

    final deleted = await repo.deleteNote(added.note!.id!);
    expect(deleted.ok, isTrue);
    expect((await repo.fetchNotes()).notes, isEmpty);
  });

  test('fetchNote mengembalikan null tanpa failure bila tidak ada', () async {
    final result = await repo.fetchNote(999);
    expect(result.note, isNull);
    expect(result.failure, isNull);
  });

  test('SyncNotes memakai implementasi SQLite nyata', () async {
    await repo.addNote(title: 'Antrean');
    final result = await SyncNotes(
      repo,
      upload: () async {},
    ).call(isOffline: () => false);
    expect(result.count, 1);
    expect((await repo.countDirty()).count, 0);
  });

  test('markSynced tidak membersihkan versi yang lebih baru', () async {
    final added = await repo.addNote(title: 'Versi awal');
    await repo.updateNote(added.note!.id!, title: 'Versi baru', body: '');
    final marked = await repo.markSynced(added.note!);
    expect(marked.ok, isTrue);
    expect((await repo.countDirty()).count, 1);
  });

  test('kegagalan database dibungkus sebagai LocalFailure', () async {
    final broken = NoteRepositoryImpl(
      openDb: () async => throw Exception('db terkunci'),
    );
    final result = await broken.fetchNotes();
    expect(result.notes, isEmpty);
    expect(result.failure, isA<LocalFailure>());
  });
}
