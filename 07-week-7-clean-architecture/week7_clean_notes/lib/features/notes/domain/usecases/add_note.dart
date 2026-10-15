import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case: menambah catatan.
///
/// Menyimpan aturan bisnis validasi (judul tidak boleh kosong) sehingga
/// widget tidak perlu tahu aturan tersebut.
class AddNote {
  const AddNote(this._repository);

  final NoteRepository _repository;

  Future<({Note? note, Failure? failure})> call({
    required String title,
    String body = '',
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Future.value((
        note: null,
        failure: const ValidationFailure('Judul catatan tidak boleh kosong.'),
      ));
    }
    return _repository.addNote(title: trimmed, body: body.trim());
  }
}
