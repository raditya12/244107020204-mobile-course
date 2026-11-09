import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case: mengubah catatan.
///
/// Sama seperti [AddNote], validasi judul adalah aturan bisnis yang tidak
/// boleh bocor ke widget.
class UpdateNote {
  const UpdateNote(this._repository);

  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call(
    int id, {
    required String title,
    required String body,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Future.value((
        note: null,
        failure: const ValidationFailure('Judul catatan tidak boleh kosong.'),
      ));
    }
    return _repository.updateNote(id, title: trimmed, body: body.trim());
  }
}
