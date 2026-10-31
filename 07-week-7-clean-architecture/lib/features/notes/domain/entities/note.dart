/// Entity bisnis murni untuk catatan.
///
/// Tanpa import Flutter dan tanpa mapping `toMap/fromMap/toJson` — mapping
/// hanya boleh hidup di layer `data` (model).
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;
}
