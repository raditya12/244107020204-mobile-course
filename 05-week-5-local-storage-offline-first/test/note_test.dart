import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/local/note.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.throwError = false});
  final bool throwError;
  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return [Note(title: 'Tes offline', updatedAt: DateTime(2026), dirty: true)];
  }
}

void main() {
  test('fromMap aman terhadap field hilang', () {
    final note = Note.fromMap({'title': 'Belanja'});
    expect(note.body, '');
    expect(note.dirty, isFalse);
    expect(note.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });
  test('dirty dan updated_at bertahan pada serialisasi', () {
    final note = Note(
      title: 'Tes',
      updatedAt: DateTime.utc(2026, 10, 3),
      dirty: true,
    );
    final restored = Note.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
    expect(restored.updatedAt, note.updatedAt);
  });
  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
      ],
    );
    addTearDown(container.dispose);
    expect(
      (await container.read(notesProvider.future)).single.title,
      'Tes offline',
    );
  });
  test('provider meneruskan error repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(throwError: true),
        ),
      ],
    );
    addTearDown(container.dispose);
    await expectLater(container.read(notesProvider.future), throwsException);
  });
  test('Note fromMap membaca data dengan benar', () {
    final map = {
      'id': 1,
      'title': 'Belajar Flutter',
      'body': 'Belajar testing',
    };

    final note = Note.fromMap(map);

    expect(note.id, 1);
    expect(note.title, 'Belajar Flutter');
    expect(note.body, 'Belajar testing');
  });
}
