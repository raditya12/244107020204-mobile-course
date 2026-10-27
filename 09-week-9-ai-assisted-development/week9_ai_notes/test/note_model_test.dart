import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_notes/features/notes/data/models/note_model.dart';

void main() {
  test('fromMap aman terhadap field hilang', () {
    final model = NoteModel.fromMap({'title': 'Belanja'});
    expect(model.body, '');
    expect(model.dirty, isFalse);
    expect(model.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('dirty dan updated_at bertahan pada serialisasi', () {
    final model = NoteModel(
      title: 'Tes',
      updatedAt: DateTime.utc(2026, 10, 3),
      dirty: true,
    );
    final restored = NoteModel.fromMap(model.toMap());
    expect(restored.dirty, isTrue);
    expect(restored.updatedAt, model.updatedAt);
  });

  test('toEntity menghasilkan entity murni tanpa mapping', () {
    final entity = NoteModel(
      id: 3,
      title: 'Belajar',
      body: 'Clean Architecture',
      updatedAt: DateTime.utc(2026),
      dirty: false,
    ).toEntity();
    expect(entity.id, 3);
    expect(entity.title, 'Belajar');
    expect(entity.dirty, isFalse);
  });
}
