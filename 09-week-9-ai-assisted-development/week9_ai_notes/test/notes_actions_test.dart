import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_notes/core/failures.dart';
import 'package:week9_ai_notes/features/notes/domain/entities/note.dart';
import 'package:week9_ai_notes/features/notes/presentation/providers/notes_actions.dart';
import 'package:week9_ai_notes/features/notes/presentation/providers/notes_providers.dart';

import 'helpers/fakes.dart';

void main() {
  test('delete menghapus catatan dari repository', () async {
    final repository = FakeNoteRepository(
      seed: [Note(id: 1, title: 'Lama', updatedAt: DateTime(2026))],
    );
    final container = ProviderContainer.test(
      overrides: [noteRepositoryProvider.overrideWithValue(repository)],
    );

    await container.read(notesActionsProvider).delete(1);

    expect((await repository.fetchNotes()).notes, isEmpty);
  });

  test('delete meneruskan kegagalan repository sebagai exception', () async {
    final repository = FakeNoteRepository(
      seed: [Note(id: 1, title: 'Lama', updatedAt: DateTime(2026))],
      deleteFailure: const LocalFailure('database terkunci'),
    );
    final container = ProviderContainer.test(
      overrides: [noteRepositoryProvider.overrideWithValue(repository)],
    );

    expect(
      () => container.read(notesActionsProvider).delete(1),
      throwsA(isA<Exception>()),
    );
    expect((await repository.fetchNotes()).notes, hasLength(1));
  });
}
