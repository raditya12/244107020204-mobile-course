# Draft issue dan Pull Request

Issue [#1](https://github.com/raditya12/244107020204-mobile-course/issues/1)
dan Pull Request
[#2](https://github.com/raditya12/244107020204-mobile-course/pull/2) sudah
dibuat dari teks di bawah. Dokumen ini disimpan sebagai template untuk PR
berikutnya.

## Issue #1

**Title**

```text
fix(notes): hapus catatan masih memanggil repository langsung dari widget
```

**Body**

```markdown
## Masalah
`notes_page.dart` memanggil `noteRepositoryProvider.deleteNote` langsung dari
widget dan mengatur invalidasi `notesProvider`, `dirtyCountProvider`, serta
`noteDetailProvider` sendiri.

## Dampak
- Presentation mengetahui detail repository.
- Logika hapus sulit diuji tanpa widget.
- Aturan invalidasi tersebar dan mudah terlewat saat ada perubahan.

## Kriteria selesai
- [ ] Widget hanya memanggil aksi presentasi (`NotesActions`).
- [ ] Invalidasi state dipusatkan di provider.
- [ ] Ada test hapus sukses dan gagal.
- [ ] `flutter analyze`, `dart format`, dan `flutter test` hijau.

## Bukti awal
`notes_page.dart:224-225` pada commit `c1aed75`.
```

## Pull Request

**Title**

```text
refactor(notes): pindahkan hapus catatan dari widget ke provider + test
```

**Body**

```markdown
## Masalah
Widget memanggil repository langsung untuk menghapus catatan dan mengatur
invalidasi state sendiri (lihat issue #1).

## Solusi
- Tambah `NotesActions` provider di
  `lib/features/notes/presentation/providers/notes_actions.dart`.
- `notes_page.dart` hanya memanggil `notesActionsProvider.delete(id)` dan
  menangani SnackBar.
- Tambah `deleteFailure` pada `FakeNoteRepository`.
- Tambah 2 test di `test/notes_actions_test.dart` (sukses dan gagal).

## Cara uji
```bash
cd 07-week-7-clean-architecture
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Manual:
1. Jalankan `flutter run -d chrome`.
2. Tambah satu catatan.
3. Tekan ikon hapus.
4. Pastikan catatan hilang, chip "Belum tersinkron" berkurang, dan tidak ada
   error di console.

## Bukti
- `flutter analyze` -> No issues found!
- `flutter test` -> 25 tests passed.
- Diff kode: 4 files, 76 insertions, 13 deletions.

Closes #1
```

## Perintah yang sudah dijalankan

```powershell
# dari root repository
git push origin 02fd10c:refs/heads/develop
git push -u origin fix/notes-delete-layer
```

PR dibuat melalui GitHub MCP:

```text
https://github.com/raditya12/244107020204-mobile-course/pull/2
```

CI `.github/workflows/ci.yml` berjalan pada PR (format, analyze, test).

## Setelah PR di-merge

```powershell
git checkout develop
git pull origin develop
git branch -d fix/notes-delete-layer
git push origin --delete fix/notes-delete-layer
```

Jangan push langsung ke `main`. `main` tetap di `c1aed75` sampai release
paruh semester disetujui.