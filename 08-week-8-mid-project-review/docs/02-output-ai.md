# Output awal AI (belum diverifikasi)

Berikut 5 temuan teratas dari sesi review awal. Semua temuan di bawah masih
mentah dan **belum boleh diterapkan** sebelum diverifikasi pada
[`ai-review-vs-keputusan.md`](ai-review-vs-keputusan.md).

## Temuan 1 - BLOCKER

**Lokasi:** `lib/features/notes/presentation/pages/notes_page.dart:224-225`
(sebelum refactor).

**Temuan:** widget halaman memanggil `noteRepositoryProvider.deleteNote`
langsung. Presentation mengetahui detail repository dan mengatur sendiri
invalidasi `notesProvider`, `dirtyCountProvider`, serta `noteDetailProvider`.

**Dampak:** logika hapus tidak bisa diuji tanpa widget, aturan invalidasi
tersebar, dan batas layer menjadi kabur. Cukup satu perubahan provider untuk
memaksa edit di banyak tempat.

**Usulan AI:**

```dart
class NotesActions {
  NotesActions(this._ref);
  final Ref _ref;

  Future<void> delete(int id) async {
    final result = await _ref.read(noteRepositoryProvider).deleteNote(id);
    if (result.failure != null) throw Exception(result.failure!.message);
    _ref.invalidate(notesProvider);
    _ref.invalidate(dirtyCountProvider);
    _ref.invalidate(noteDetailProvider(id));
  }
}
```

Lalu widget cukup memanggil `ref.read(notesActionsProvider).delete(id)`.

## Temuan 2 - BLOCKER (klaim)

**Lokasi:** `lib/features/notes/presentation/**`.

**Temuan:** presentation tampaknya mengimpor `NoteModel` atau `sqflite` untuk
mapping data, sehingga dependency rule `presentation -> domain <- data`
dilanggar.

**Usulan AI:** pindahkan seluruh mapping ke `data` dan hapus import framework
dari presentation.

## Temuan 3 - SARAN

**Lokasi:** `test/`.

**Temuan:** belum ada test untuk jalur hapus catatan. Test yang ada menguji
tambah, ubah, sinkronisasi, repository, dan widget, tetapi tidak menguji
sukses/gagal hapus.

**Dampak:** regresi pada aksi hapus tidak terdeteksi sampai diuji manual.

**Usulan AI:** tambah dua test: hapus sukses dan repository mengembalikan
failure. Gunakan fake repository, bukan SQLite asli.

## Temuan 4 - SARAN

**Lokasi:** `lib/features/notes/presentation/providers/notes_providers.dart:49-51`
(sebelum refactor).

```dart
final dirtyCountProvider = FutureProvider<int>((ref) async {
  final result = await ref.watch(noteRepositoryProvider).countDirty();
  return result.count;
});
```

**Temuan:** `result.failure` diabaikan. Bila query gagal, UI membaca nilai
default `0` dan menampilkan "Belum tersinkron: 0" seolah semuanya berhasil.

**Usulan AI:** lempar failure atau tampilkan status error terpisah di UI.

## Temuan 5 - SARAN (over-engineering)

**Temuan/usulan AI:** tambahkan `freezed` untuk entity, `Either<Failure, T>`
untuk semua hasil, `get_it` untuk DI, dan base class `UseCase<Type, Params>`
termasuk `DeleteNote`.

**Alasan AI:** agar konsisten dengan template Clean Architecture populer dan
memudahkan testing.

## Temuan tambahan di luar 5 teratas

**Lokasi:** `lib/features/notes/data/repositories/note_repository_impl.dart:84-98`.

**Temuan:** `db.update` yang tidak menemukan baris (id sudah dihapus) tetap
dilaporkan sukses karena jumlah baris terpengaruh tidak diperiksa.

**Usulan AI:** periksa return value `db.update`; bila `0`, kembalikan
`LocalFailure('Catatan tidak ditemukan')`.

## Ringkasan level

| # | Level | Inti temuan |
|---|---|---|
| 1 | blocker | widget memanggil repository langsung |
| 2 | blocker (klaim) | presentation mengimpor model/framework |
| 3 | saran | belum ada test jalur hapus |
| 4 | saran | failure `countDirty` ditelan |
| 5 | saran | over-engineering `freezed`/`Either`/`get_it` |
| + | saran | `updateNote` sukses saat id tidak ada |