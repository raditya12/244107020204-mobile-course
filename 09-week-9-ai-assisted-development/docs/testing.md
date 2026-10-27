# Hasil Testing — Jobsheet 9

**Tanggal:** 27 Oktober 2026
**Project:** `week9_ai_notes`
**Fokus:** pencarian judul catatan + empty state

## Ringkasan

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | `No issues found!` |
| `dart format --set-exit-if-changed` | exit 0, tidak ada file berubah |
| `flutter test` | 31 test, semua hijau |
| Test baru | 6 (5 domain + 1 widget) |
| Uji manual | 3 skenario, screenshot tersedia |

## Test baru

### `test/search_notes_test.dart`

| Test | Input | Harapan |
|---|---|---|
| Query kosong | `''` dan `'   '` | Semua 3 catatan |
| Case-insensitive | `'belanja'` | 2 catatan (`Belanja bulanan`, `Rapat BELANJA tim`) |
| Trim | `'  Rapat  '` | 1 catatan |
| Tidak cocok | `'zzz-tak-ada'` | Daftar kosong |
| Judul saja | `'susu'` (hanya ada di body) | Daftar kosong |

Test case-insensitive adalah test yang sempat merah pada draft AI pertama.
Bukti output merah dan perbaikannya ada di
[`ai-log.md`](ai-log.md#4-bukti-bughalusinasi).

### `test/search_widget_test.dart`

Satu widget test memakai `FakeNoteRepository` (tanpa SQLite/jaringan):

1. Dua catatan awal tampil.
2. Query `belanja` hanya menampilkan `Belanja bulanan`.
3. Query `zzz-tak-ada` menampilkan `notes-search-empty`.
4. Tombol `Hapus pencarian` mengembalikan kedua catatan.

## Uji manual

Build web dijalankan lokal, lalu diuji lewat browser.

| Skenario | Input | Hasil | Screenshot |
|---|---|---|---|
| Daftar catatan | Tanpa query | 3 catatan tampil | [`00-daftar-catatan.png`](../screenshots/00-daftar-catatan.png) |
| Pencarian cocok | `rapat` | Hanya `Rapat tim` yang tampil | [`01-search-cocok.png`](../screenshots/01-search-cocok.png) |
| Pencarian tidak cocok | `zzz-tak-ada` | Empty state dan tombol hapus pencarian | [`02-search-kosong.png`](../screenshots/02-search-kosong.png) |
| Hapus pencarian | Klik `Hapus pencarian` | Query kosong, semua catatan kembali | Diuji di UI dan widget test |

## Perintah dan output

```text
flutter test test/search_notes_test.dart test/search_widget_test.dart
00:00 +6: All tests passed!
```

```text
flutter analyze
No issues found! (ran in 127.5s)
```

```text
dart format --output=none --set-exit-if-changed lib test
Formatted 46 files (0 changed) in 0.12 seconds.
format_exit=0
```

```text
flutter test
+31: All tests passed!
```

## Catatan teknis

- Test domain tidak mengimpor Flutter, SQLite, Dio, atau Riverpod.
- Widget test meng-override `noteRepositoryProvider`, `postRepositoryProvider`,
  dan `prefsRepositoryProvider` agar deterministik.
- Screenshot diambil dari build web nyata, bukan mockup.
- Data catatan pada screenshot dibuat lewat UI (tambah catatan), bukan
  di-seed langsung ke database.