import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../infrastructure/database/db.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/sync_notes.dart';
import '../../domain/usecases/update_note.dart';

/// Satu-satunya tempat wiring dependensi fitur `notes`.
///
/// Data layer: database opener disuntikkan (mudah diganti fake saat test).
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openDb: openNotesDb);
});

// Domain layer: use case menerima abstraksi, bukan implementasi.
final getNotesProvider = Provider<GetNotes>(
  (ref) => GetNotes(ref.watch(noteRepositoryProvider)),
);
final addNoteProvider = Provider<AddNote>(
  (ref) => AddNote(ref.watch(noteRepositoryProvider)),
);
final updateNoteProvider = Provider<UpdateNote>(
  (ref) => UpdateNote(ref.watch(noteRepositoryProvider)),
);
final syncNotesProvider = Provider<SyncNotes>(
  (ref) => SyncNotes(ref.watch(noteRepositoryProvider)),
);

// Presentation layer: state untuk UI.
final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.notes;
}, retry: (_, _) => null);

final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final result = await ref.watch(noteRepositoryProvider).fetchNote(id);
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.note;
}, retry: (_, _) => null);

final dirtyCountProvider = FutureProvider<int>((ref) async {
  final result = await ref.watch(noteRepositoryProvider).countDirty();
  return result.count;
});

final syncProvider = AsyncNotifierProvider<SyncNotifier, int>(SyncNotifier.new);

class SyncNotifier extends AsyncNotifier<int> {
  @override
  FutureOr<int> build() => 0;

  Future<void> synchronize() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(syncNotesProvider).call(
        isOffline: () => ref.read(forceOfflineProvider),
      );
      if (result.failure != null) throw Exception(result.failure!.message);
      return result.count;
    });
    ref.invalidate(notesProvider);
    ref.invalidate(dirtyCountProvider);
    ref.invalidate(noteDetailProvider);
  }
}
