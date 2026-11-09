import '../entities/note.dart';

/// Use case: menyaring catatan berdasarkan judul.
///
/// Use case ini murni Dart dan tidak menyentuh SQLite, Dio, atau widget.
class SearchNotes {
  const SearchNotes();

  List<Note> call(List<Note> notes, String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return notes;
    return notes
        .where((note) => note.title.toLowerCase().contains(keyword))
        .toList();
  }
}
