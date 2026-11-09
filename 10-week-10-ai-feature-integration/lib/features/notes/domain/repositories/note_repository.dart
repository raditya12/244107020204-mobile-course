import '../../../../core/failures.dart';
import '../entities/note.dart';

/// Kontrak yang dibutuhkan domain. Implementasi (SQLite) hidup di layer
/// `data`, sehingga domain tidak tahu detail penyimpanan.
///
/// Setiap operasi mengembalikan *record* sukses/gagal agar exception mentah
/// tidak bocor ke presentation.
abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();

  Future<({Note? note, Failure? failure})> fetchNote(int id);

  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body,
  });

  Future<({Note? note, Failure? failure})> updateNote(
    int id, {
    required String title,
    required String body,
  });

  Future<({bool ok, Failure? failure})> deleteNote(int id);

  Future<({int count, Failure? failure})> countDirty();

  Future<({bool ok, Failure? failure})> markSynced(Note note);
}
