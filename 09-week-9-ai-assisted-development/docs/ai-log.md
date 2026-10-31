# AI Log — Jobsheet 9

**Tanggal:** 27 Oktober 2026
**Asisten:** OpenCode (AI coding assistant)
**Project basis:** `07-week-7-clean-architecture` (Minggu 7)
**Project kerja:** `09-week-9-ai-assisted-development`
**Fitur:** pencarian judul catatan + empty state

## 1. Prompt 5 slot

```text
Peran: senior Flutter developer yang disiplin Clean Architecture.
Konteks: project Week 9 (salinan project Minggu 7), feature-first,
presentation -> domain <- data, Riverpod 3, SQLite, Dio, GoRouter.
Tugas: tambah pencarian judul catatan + empty state.
Batas: jangan ubah arsitektur; jangan panggil SQLite/Dio dari widget;
maksimal 80 baris kode baru; jangan ubah entity/repository.
Output: kode use case + provider + widget, minimal 1 test sukses dan
1 test gagal, dan cara uji manual.
```

### Konteks yang ditempel

Struktur folder yang relevan:

```text
lib/features/notes/
├── data/
│   ├── models/note_model.dart
│   └── repositories/note_repository_impl.dart
├── domain/
│   ├── entities/note.dart
│   ├── repositories/note_repository.dart
│   └── usecases/{add,get,sync,update}_note.dart
└── presentation/
    ├── pages/notes_page.dart
    ├── providers/{notes_actions,notes_providers}.dart
    └── widgets/note_tile.dart
```

Versi package dari `pubspec.yaml`: `flutter_riverpod` 3.4.3, `sqflite` 2.4.4,
`dio` 5.11.1, `go_router` 18.0.2, `shared_preferences` 2.5.5.

Kontrak entity yang tidak boleh diubah:

```dart
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
```

Batas yang ditegaskan: jangan mengubah `Note`, `NoteRepository`, layer `data`,
dan wiring `noteRepositoryProvider`. Tidak ada token atau secret yang ditempel.

## 2. Output awal AI

Draft pertama menaruh filter di domain use case, tetapi memakai
`String.contains` secara langsung:

```dart
class SearchNotes {
  const SearchNotes();

  List<Note> call(List<Note> notes, String query) {
    final keyword = query.trim();
    if (keyword.isEmpty) return notes;
    return notes.where((note) => note.title.contains(keyword)).toList();
  }
}
```

Draft ini lolos `flutter analyze`, tetapi belum terbukti benar. Verifikasi
langkah 5 menemukan bug pada pencocokan huruf besar/kecil.

## 3. Verifikasi 6 langkah

| Langkah | Yang dilakukan | Hasil |
|---|---|---|
| 1. Baca tiap baris | Menandai `contains` yang belum menormalkan huruf | Ditemukan bug case-sensitive |
| 2. Cek import | Memastikan `domain/` hanya mengimpor entity | 0 import Flutter/Dio/SQLite/Riverpod |
| 3. Cek API | `trim`, `toLowerCase`, `contains`, `NotifierProvider`, `whenData` | Semua ada di Dart/Riverpod 3 |
| 4. Analyze | `flutter analyze` | `No issues found!` |
| 5. Test | Test sukses + test gagal | Merah saat draft, hijau setelah diperbaiki |
| 6. Uji manual | Query kosong, cocok, tidak cocok | Terlihat di `screenshots/` |

## 4. Bukti bug/halusinasi

Pola yang ditemukan: **logika yakin tapi salah** (bukan method fiktif).
Filter memakai perbandingan case-sensitive, sehingga query `belanja` tidak
menemukan judul `Belanja bulanan`.

Test pembuktian:

```dart
test('pencarian judul mengabaikan huruf besar/kecil', () {
  expect(search(notes, 'belanja'), hasLength(2));
});
```

Output merah sebelum perbaikan:

```text
00:00 +1 -1: pencarian judul mengabaikan huruf besar/kecil [E]
  Expected: an object with length of <2>
    Actual: []
     Which: has length of <0>

  package:matcher                                     expect
  test\search_notes_test.dart 31:5                    main.<fn>

00:00 +4 -1: Some tests failed.
```

Akar masalah: `String.contains` bersifat case-sensitive. Data berisi
`Belanja bulanan` dan `Rapat BELANJA tim`, sedangkan query ditulis `belanja`.

Perbaikan di `lib/features/notes/domain/usecases/search_notes.dart:10-14`:

```dart
final keyword = query.trim().toLowerCase();
if (keyword.isEmpty) return notes;
return notes
    .where((note) => note.title.toLowerCase().contains(keyword))
    .toList();
```

Setelah perbaikan:

```text
00:00 +6: All tests passed!
```

## 5. AI review challenge

Prompt review yang dipakai:

```text
Review kode search Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

Temuan dan keputusan:

| # | Temuan AI | Level | Keputusan | Alasan teknis dan bukti |
|---|---|---|---|---|
| 1 | Filter judul masih case-sensitive | Blocker | **Diterima dan diperbaiki** | Test `'belanja'` mengharapkan 2 hasil, aktual 0. Diperbaiki dengan `toLowerCase()` pada query dan judul. |
| 2 | Tambahkan `searchNotes()` ke `NoteRepository` dan query SQL `LIKE` | Blocker (usulan arsitektur) | **Ditolak** | Kontrak `NoteRepository` tidak punya method itu (grep 0 match). Search bekerja pada daftar yang sudah dimuat; menambah method, migrasi, dan index untuk fitur kecil melanggar batas prompt serta menduplikasi aturan filter di data layer. |
| 3 | Ganti field inline dengan `SearchAnchor`/`SearchDelegate` | Saran | **Ditolak** | Overkill untuk satu field. `SearchAnchor` menambah route/overlay, mempersulit empty state, dan memperbesar perubahan UI. Field inline sudah lolos 1 widget test. |
| 4 | Debounce query 300 ms | Saran | **Ditolak** | Filter berjalan di memori tanpa I/O per ketikan. Timer menambah kompleksitas dan berpotensi membuat widget test flaky tanpa manfaat terukur. |
| 5 | Tampilkan jumlah hasil dan highlight kecocokan | Saran | **Ditunda** | Bukan bagian jobsheet. Highlight membutuhkan `RichText` dan mengubah `NoteTile`; dicatat sebagai ide lanjutan, bukan scope fitur kecil. |

### Keputusan tiap file

| File | Keputusan | Catatan |
|---|---|---|
| `domain/usecases/search_notes.dart` | Terima + refactor | Draft AI diperbaiki menjadi case-insensitive. |
| `presentation/providers/notes_providers.dart` | Terima | Provider use case, query, dan hasil turunan. |
| `presentation/widgets/notes_search_field.dart` | Terima + refactor | Controller disinkronkan dengan provider agar tombol clear bekerja. |
| `presentation/pages/notes_page.dart` | Terima + refactor | Empty state diekstrak; widget tidak memfilter sendiri. |
| `test/search_notes_test.dart` | Terima + perluas | 5 kasus, termasuk kasus yang sempat merah. |
| `test/search_widget_test.dart` | Terima | 1 widget test untuk hasil cocok, empty state, dan clear. |

## 6. Bukti grep

### Domain murni

```powershell
Get-ChildItem -Path lib\features\notes\domain -Recurse -Filter *.dart |
  Select-String -Pattern "package:flutter|package:dio|package:sqflite|package:riverpod"
# => 0 matches
```

### Widget tidak mengakses repository dan tidak memfilter sendiri

```powershell
Get-ChildItem -Path lib\features\notes\presentation\pages\notes_page.dart,
  lib\features\notes\presentation\widgets\notes_search_field.dart |
  Select-String -Pattern 'noteRepositoryProvider|\.contains\('
# => 0 matches
```

### Tidak ada method search di data layer

```powershell
Get-ChildItem -Path lib\features\notes\domain\repositories,
  lib\features\notes\data -Recurse -Filter *.dart |
  Select-String -Pattern 'searchNotes|LIKE'
# => 0 matches
```

### Search hanya dipakai di presentation

```text
lib\features\notes\presentation\providers\notes_providers.dart:36:
  final searchNotesProvider = Provider<SearchNotes>((ref) => const SearchNotes());
lib\features\notes\presentation\providers\notes_providers.dart:63:
  (items) => ref.watch(searchNotesProvider).call(items, query),
```

## 7. Bukti mesin

```text
flutter analyze
No issues found! (ran in 127.5s)

dart format --output=none --set-exit-if-changed lib test
Formatted 46 files (0 changed) in 0.12 seconds.
format_exit=0

flutter test
+31: All tests passed!
```

## 8. Checklist verifikasi mandiri

- [x] Prompt 5 slot + konteks tersimpan di dokumen ini.
- [x] `flutter analyze` bersih dan `flutter test` hijau.
- [x] Satu temuan AI dibuktikan benar lewat test merah lalu diperbaiki.
- [x] Satu temuan AI ditolak dengan alasan teknis tertulis.
- [x] Keputusan tiap file dicatat.
- [x] Mampu menjelaskan keputusan tanpa membuka AI (lihat refleksi README).