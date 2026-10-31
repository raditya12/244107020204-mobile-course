import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notes_providers.dart';

/// Aksi tulis catatan yang dipakai widget.
///
/// Widget tidak lagi mengakses repository langsung; pemanggilan data dan
/// invalidasi state dikumpulkan di satu tempat agar UI tetap tipis.
class NotesActions {
  NotesActions(this._ref);

  final Ref _ref;

  Future<void> delete(int id) async {
    final result = await _ref.read(noteRepositoryProvider).deleteNote(id);
    if (result.failure != null) {
      throw Exception(result.failure!.message);
    }
    _ref.invalidate(notesProvider);
    _ref.invalidate(dirtyCountProvider);
    _ref.invalidate(noteDetailProvider(id));
  }
}

final notesActionsProvider = Provider<NotesActions>((ref) => NotesActions(ref));
