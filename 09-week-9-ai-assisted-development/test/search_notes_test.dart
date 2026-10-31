import 'package:flutter_test/flutter_test.dart';
import 'package:week9_ai_notes/features/notes/domain/entities/note.dart';
import 'package:week9_ai_notes/features/notes/domain/usecases/search_notes.dart';

void main() {
  const search = SearchNotes();
  final notes = <Note>[
    Note(
      title: 'Belanja bulanan',
      body: 'susu telur',
      updatedAt: DateTime(2026, 10, 27),
    ),
    Note(
      title: 'Rapat BELANJA tim',
      body: 'agenda',
      updatedAt: DateTime(2026, 10, 27),
    ),
    Note(
      title: 'Catatan biasa',
      body: 'belanja ada di isi, bukan judul',
      updatedAt: DateTime(2026, 10, 27),
    ),
  ];

  test('query kosong mengembalikan semua catatan', () {
    expect(search(notes, ''), hasLength(3));
    expect(search(notes, '   '), hasLength(3));
  });

  test('pencarian judul mengabaikan huruf besar/kecil', () {
    expect(search(notes, 'belanja'), hasLength(2));
  });

  test('query di-trim sebelum dicocokkan', () {
    expect(search(notes, '  Rapat  '), hasLength(1));
  });

  test('query tidak cocok mengembalikan daftar kosong', () {
    expect(search(notes, 'zzz-tak-ada'), isEmpty);
  });

  test('pencarian hanya membaca judul, bukan isi', () {
    expect(search(notes, 'susu'), isEmpty);
  });
}
