# Peer review

Status: review dilakukan pada Pull Request
[#2](https://github.com/raditya12/244107020204-mobile-course/pull/2).
Diff yang direview: `develop..fix/notes-delete-layer` pada project
`07-week-7-clean-architecture/week7_clean_notes`.

Issue yang menjadi dasar review:
[#1](https://github.com/raditya12/244107020204-mobile-course/issues/1).

> **#1 fix(notes): hapus catatan masih memanggil repository langsung dari widget**
>
> **Masalah:** `notes_page.dart` memanggil `noteRepositoryProvider.deleteNote`
> dan mengatur invalidasi provider sendiri. Widget mengetahui detail data layer.
>
> **Dampak:** logika hapus sulit diuji tanpa widget dan aturan invalidasi
> tersebar.
>
> **Kriteria selesai:** widget hanya memanggil aksi presentasi; ada test sukses
> dan gagal; `flutter analyze`, `dart format`, dan `flutter test` hijau.

## Komentar review

### 1. Arsitektur - request changes

**Observasi:** `notes_page.dart:224-225` (sebelum perubahan) membaca
`noteRepositoryProvider` langsung dari widget.

**Dampak:** presentation bergantung pada detail repository dan mengatur
invalidasi tiga provider. Perubahan aturan hapus memaksa edit di UI.

**Usulan konkret:** pindahkan pemanggilan dan invalidasi ke `NotesActions`
provider; widget hanya menangani SnackBar.

**Respons author:** diterapkan pada `notes_actions.dart`. Widget sekarang
memanggil `ref.read(notesActionsProvider).delete(id)`.

**Status:** resolved.

### 2. Test - request changes

**Observasi:** dari 23 test, tidak ada yang menguji jalur hapus.

**Dampak:** kegagalan hapus (misalnya database terkunci) tidak terdeteksi.

**Usulan konkret:** tambah dua test memakai `FakeNoteRepository`: hapus sukses
dan repository mengembalikan `LocalFailure`.

**Respons author:** ditambahkan `test/notes_actions_test.dart` (2 test). Total
test menjadi 25 dan semuanya hijau.

**Status:** resolved.

### 3. Error path - saran (ditolak dengan alasan)

**Observasi:** SnackBar masih menampilkan pesan umum "Gagal menghapus catatan."
tanpa detail failure.

**Dampak:** pengguna tidak tahu penyebab, tetapi detail teknis juga tidak cocok
ditampilkan.

**Usulan konkret:** tampilkan `failure.message` langsung di SnackBar.

**Respons author:** ditolak. `failure.message` dapat memuat detail SQLite
(nama tabel/constraint). UI tetap memakai pesan umum; detail tetap tersedia
pada exception untuk debugging dan test.

**Status:** closed, tidak diterapkan.

### 4. Keterbacaan - saran (ditunda)

**Observasi:** `_edit` di `notes_page.dart` masih panjang (dialog, simpan,
invalidasi, dispose controller).

**Dampak:** sulit dibaca, tetapi tidak memblokir perilaku.

**Usulan konkret:** ekstrak dialog ke widget `NoteEditorDialog`.

**Respons author:** dicatat sebagai issue lanjutan. PR ini sengaja dibatasi
pada pelanggaran layer dan test agar tetap di bawah 300 baris.

**Status:** deferred, bukan blocker.

### 5. Penamaan - saran (ditolak)

**Observasi:** nama `NotesActions` dianggap kurang umum dibanding
`NotesController`.

**Usulan konkret:** ganti menjadi `NotesController`.

**Respons author:** tetap `NotesActions` karena kelas ini hanya berisi aksi
tulis dan tidak memegang state. Nama `Controller` akan menyesatkan.

**Status:** closed, tidak diterapkan.

## Keputusan akhir

**Approve** setelah komentar 1 dan 2 diperbaiki. Komentar 3 dan 5 ditolak
dengan alasan tertulis; komentar 4 ditunda dan dicatat sebagai tindak lanjut.

Reviewer menjalankan sendiri:

```text
flutter analyze                              -> No issues found!
dart format --output=none --set-exit-if-changed lib test -> exit 0
flutter test                                 -> +25 All tests passed!
```

Perubahan hanya memindahkan pemanggilan dari widget ke provider, sehingga
perilaku UI identik dengan akhir Minggu 7 (lihat folder `screenshots/`).