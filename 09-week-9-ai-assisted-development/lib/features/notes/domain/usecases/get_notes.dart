import '../../../../core/failures.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// Use case: membaca seluruh catatan.
///
/// Use case ini tipis (pass-through) namun dipertahankan sebagai titik masuk
/// domain yang diuji, sesuai contoh jobsheet. Operasi baca lain yang juga
/// satu baris (detail, hitung dirty) sengaja tidak dibuatkan use case agar
/// tidak over-engineering.
class GetNotes {
  const GetNotes(this._repository);

  final NoteRepository _repository;

  Future<({List<Note> notes, Failure? failure})> call() {
    return _repository.fetchNotes();
  }
}
