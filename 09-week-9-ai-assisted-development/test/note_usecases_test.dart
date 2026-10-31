import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_notes/core/failures.dart';
import 'package:week9_ai_notes/features/notes/domain/entities/note.dart';
import 'package:week9_ai_notes/features/notes/domain/usecases/add_note.dart';
import 'package:week9_ai_notes/features/notes/domain/usecases/update_note.dart';

import 'helpers/fakes.dart';

void main() {
  group('AddNote', () {
    test('menolak judul kosong dengan ValidationFailure', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo).call(title: '   ');
      expect(result.failure, isA<ValidationFailure>());
      expect(result.note, isNull);
      expect((await repo.fetchNotes()).notes, isEmpty);
    });

    test('memangkas judul dan menyimpan catatan', () async {
      final repo = FakeNoteRepository();
      final result = await AddNote(repo)
          .call(title: '  Belanja  ', body: ' susu ');
      expect(result.failure, isNull);
      expect(result.note!.title, 'Belanja');
      expect(result.note!.body, 'susu');
      expect(result.note!.dirty, isTrue);
    });

    test('meneruskan kegagalan repository', () async {
      final repo = FakeNoteRepository(
        writeFailure: const LocalFailure('disk penuh'),
      );
      final result = await AddNote(repo).call(title: 'X');
      expect(result.failure, isA<LocalFailure>());
    });
  });

  group('UpdateNote', () {
    test('menolak judul kosong tanpa mengubah data', () async {
      final repo = FakeNoteRepository(
        seed: [Note(id: 1, title: 'Lama', updatedAt: DateTime(2026))],
      );
      final result = await UpdateNote(repo).call(1, title: '', body: 'baru');
      expect(result.failure, isA<ValidationFailure>());
      expect((await repo.fetchNote(1)).note!.title, 'Lama');
    });

    test('mengubah catatan dan menandainya dirty', () async {
      final repo = FakeNoteRepository(
        seed: [Note(id: 1, title: 'Lama', updatedAt: DateTime(2026))],
      );
      final result = await UpdateNote(repo).call(1, title: 'Baru', body: 'isi');
      expect(result.failure, isNull);
      expect(result.note!.dirty, isTrue);
      expect((await repo.fetchNote(1)).note!.title, 'Baru');
    });
  });
}
