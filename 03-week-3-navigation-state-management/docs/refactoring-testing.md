# Verifikasi refactoring dan testing — Jobsheet 3

Tanggal: 20 September 2026.

## Implementasi dan pemeriksaan hasil AI

- `lib/widgets/todo_tile.dart`: baris ToDo terpisah dengan callback toggle/hapus.
- `lib/providers/todo_provider.dart`: filter merupakan Provider turunan yang
  membaca daftar dan pilihan filter menggunakan `ref.watch`.
- Setiap tugas mempunyai ID stabil. ID dipertahankan oleh `copyWith`, sehingga
  aksi pada hasil filter tidak salah mengubah tugas dengan indeks berbeda.
- Tambah/toggle/hapus menghasilkan list baru; test memastikan state lama tidak
  berubah. Judul kosong ditolak dan spasi tepi judul dibuang.
- `lib/router/app_router.dart`: GoRouter dikelola Provider dan dibuang ketika
  ProviderScope dilepas. ShellRoute membungkus `/` dan `/stats` dengan
  NavigationBar. Push ke statistik memungkinkan back ke daftar; pilihan
  Daftar menggunakan go ke `/`.
- `lib/main.dart`: ProviderScope berada di atas MaterialApp.router. Data tetap
  tersimpan saat berpindah halaman, tetapi belum disimpan permanen ke disk.
- Statistik menggunakan simulasi AI challenge sebelumnya; loading, error,
  retry, dan success tetap diuji dengan hasil acak terkontrol.

## Perintah dan hasil aktual

Working directory: `03-week-3-navigation-state-management/`.

```text
flutter pub get
Resolving dependencies... (berhasil, termasuk go_router 18.0.1)

dart format lib test
Formatted 14 files (9 changed).

flutter analyze
No issues found!

flutter test
+14: All tests passed!
```

## Cakupan 14 test

| File | Jumlah | Pemeriksaan |
| --- | ---: | --- |
| `test/stats_notifier_test.dart` | 6 | Loading/delay, data, batas peluang error, retry |
| `test/widget_test.dart` | 1 | UI AsyncValue: loading → error → retry → success |
| `test/todo_provider_test.dart` | 2 | Filter reaktif, ID stabil, immutable state, validasi judul |
| `test/todo_tile_test.dart` | 1 | Checkbox, teks tercoret, callback toggle dan hapus |
| `test/todo_app_test.dart` | 4 | Tambah tugas, aksi pada filter, navigasi/back/state, direct route |

## Checklist jobsheet

- [x] TodoTile terpisah dan diuji secara mandiri.
- [x] Filter membaca todoListProvider melalui Provider turunan.
- [x] Navigasi daftar/statistik melalui NavigationBar berjalan.
- [x] Back dari statistik kembali ke daftar melalui `handlePopRoute` di test.
- [x] Akses langsung `/stats` diuji menggunakan initialLocation GoRouter.
- [x] ProviderScope membungkus root; tugas bertahan ketika berpindah halaman.
- [x] UI AsyncValue menangani loading, error, retry, dan success.
- [x] `flutter analyze` tanpa issue; semua 14 test lulus.
- [x] Hasil implementasi AI diperiksa dan didokumentasikan dalam `docs/`.

Verifikasi navigasi di atas dilakukan melalui widget test. Demo manual pada
perangkat dan verifikasi tombol back browser belum dilakukan pada sesi ini.
