import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/domain/usecases/sync_notes.dart';

import 'helpers/fakes.dart';

void main() {
  test('mode offline menolak sinkronisasi tanpa mengubah antrean', () async {
    final repo = FakeNoteRepository(
      seed: [Note(title: 'A', updatedAt: DateTime(2026), dirty: true)],
    );
    final result = await SyncNotes(repo).call(isOffline: () => true);
    expect(result.failure, isA<NetworkFailure>());
    expect(result.count, 0);
    expect((await repo.countDirty()).count, 1);
  });

  test('mengirim catatan dirty berurutan dan menandainya tersinkron', () async {
    final uploaded = <String>[];
    final repo = FakeNoteRepository(
      seed: [
        Note(title: 'Kedua', updatedAt: DateTime(2026, 2), dirty: true),
        Note(title: 'Pertama', updatedAt: DateTime(2026, 1), dirty: true),
      ],
    );
    final result = await SyncNotes(
      repo,
      upload: () async => uploaded.add('x'),
    ).call(isOffline: () => false);

    expect(result.failure, isNull);
    expect(result.count, 2);
    expect(uploaded.length, 2);
    expect(repo.syncedTitles, ['Pertama', 'Kedua']);
    expect((await repo.countDirty()).count, 0);
  });

  test('upload gagal mempertahankan status dirty', () async {
    final repo = FakeNoteRepository(
      seed: [Note(title: 'Antrean', updatedAt: DateTime(2026), dirty: true)],
    );
    final result = await SyncNotes(
      repo,
      upload: () async => throw Exception('Server gagal'),
    ).call(isOffline: () => false);

    expect(result.failure, isA<LocalFailure>());
    expect(result.count, 0);
    expect((await repo.countDirty()).count, 1);
  });

  test('edit ketika upload berlangsung tetap dirty', () async {
    final repo = FakeNoteRepository(
      seed: [Note(id: 1, title: 'Versi awal', updatedAt: DateTime(2026), dirty: true)],
    );
    final result = await SyncNotes(
      repo,
      upload: () async {
        await repo.updateNote(1, title: 'Versi baru', body: 'belum dikirim');
      },
    ).call(isOffline: () => false);

    expect(result.count, 1);
    expect((await repo.countDirty()).count, 1);
  });
}
