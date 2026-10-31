# Hasil testing dan verifikasi

Tanggal: 15 Oktober 2026.

## Pemeriksaan kode

```text
flutter analyze
No issues found! (ran in 4.5s)

flutter test
All tests passed! (23 tests)

flutter build web
√ Built build\web
```

## Pengujian aplikasi aktual (before/after)

Aplikasi direfactor tanpa mengubah perilaku. Skenario otomatis dijalankan pada
build web dengan Chrome headless (Playwright), memakai aksi UI nyata:

```text
result: PASS
screenshots: 9
page_errors: []

observations:
- API cache: 100 posts
- offline dirty: 2
- SQLite persists after reload
- offline create/edit/delete: PASS
- sync dirty: 2 -> 0
- dark preference persists after reload
- detail route reads local note after direct reload
```

Perintah:

```bash
flutter build web
python -m http.server 8765 --bind 127.0.0.1 --directory build/web
python tool/capture_screenshots.py
```

## Perbandingan before vs after

Screenshot "before" diambil dari project Minggu 5 (`week5_offline_notes`) dan
disalin ke `screenshots/before/`. Screenshot "after" diambil dari project
hasil refactor ke `screenshots/after/`. UI identik; yang berubah hanya
struktur kode.

| Aspek | Before (Minggu 5) | After (Minggu 7) |
|---|---|---|
| Struktur | layer-first (`data/`, `local/`, `pages/`, `widgets/`) | feature-first (`features/{notes,posts,settings}/{domain,data,presentation}`) |
| Entity | `local/note.dart` + mapping bercampur | entity murni + `NoteModel` di data |
| Repository | interface + impl satu kelas | interface di domain, impl di data |
| Sync | `data/sync.dart` | `domain/usecases/sync_notes.dart` |
| DI | `data/providers.dart` + provider di `settings_page.dart` | provider per fitur + `app/providers.dart` |
| Format tanggal | inline di widget | `core/format.dart` (fungsi murni) |
| Test | 13 | 23 |
| `flutter analyze` | bersih | bersih |

## Cakupan test otomatis

- `get_notes_test.dart`: use case `GetNotes` sukses dan failure dengan
  repository palsu (wajib jobsheet).
- `note_usecases_test.dart`: validasi `AddNote`/`UpdateNote` dan delegasi.
- `sync_notes_test.dart`: offline menolak sync, urutan `updatedAt`, upload
  gagal tetap dirty, edit saat upload tetap dirty.
- `note_repository_impl_test.dart`: CRUD SQLite in-memory, `markSynced` tidak
  membersihkan versi lebih baru, kegagalan dibungkus `LocalFailure`.
- `note_model_test.dart`: mapping `fromMap`/`toMap` dan `toEntity`.
- `posts_usecases_test.dart`: cache-first, mode offline tidak memanggil API,
  failure jaringan diteruskan tanpa melempar.
- `widget_test.dart`: UI kosong, toggle offline, dialog tambah catatan.

## Verifikasi manual (5 menit per fitur)

Setelah refactor, tiap fitur diuji manual pada build web: catatan (tambah,
edit, hapus, detail, sync), cache bacaan, dan pengaturan tema. Hasilnya sama
seperti sebelum refactor (lihat screenshot before/after).
