# Step 7 — Verifikasi mini project dan laporan

Tanggal verifikasi: 20 September 2026.

## Acuan

[Step 7 codelab Navigation & State Management](https://jti-polinema.github.io/flutter-codelab/03-minggu-3-navigation-state-management/index.html#6)
meminta mini project ToDo, dokumentasi, test, pengumpulan ke repository, dan
empat jawaban refleksi. Laporan lengkap disusun di [README utama](../README.md).

## Pemenuhan tugas

- [x] Dua halaman: daftar `/` dan statistik `/stats`, melalui GoRouter.
- [x] State ToDo menggunakan NotifierProvider; halaman menggunakan ConsumerWidget.
- [x] Statistik memakai AsyncNotifierProvider dengan loading, error, success.
- [x] Tombol retry menjalankan ulang pengambilan statistik.
- [x] Unit/widget test aplikasi utama lulus.
- [x] Prompt, hasil awal AI, audit, perbaikan, dan testing tersedia di `docs/ai-challenge/`.
- [x] README berisi tujuan, fitur, teknologi, cara menjalankan, hasil, dan refleksi.
- [x] Struktur `lib/`, `test/`, `README.md`, `screenshots/` berada pada folder minggu ke-3.
- [x] Seluruh 14 gambar di folder screenshots ditautkan dalam laporan.

## Perubahan pada penyelesaian step 7

1. Menyusun ulang README menjadi laporan step 1–7 berdasarkan codelab dan
   implementasi yang benar-benar tersedia.
2. Memasukkan enam screenshot praktikum awal dan delapan screenshot refactoring
   ke bagian yang sesuai, dengan caption yang menjelaskan isi gambar.
3. Menambahkan refleksi setState/Riverpod, go/push, AsyncValue, dan perbaikan AI.
4. Mendokumentasikan keputusan penggunaan ID stabil, Provider filter, dan
   batasan data in-memory serta statistik simulasi.
5. Mengganti test counter bawaan di proyek `week3_navigation` karena masih
   memeriksa angka counter/tombol tambah yang tidak ada pada aplikasi navigasi.
   Test pengganti memeriksa Home, Detail 3, back, dan path `/detail/9`.

## Hasil perintah aktual

### Aplikasi ToDo utama

Working directory: `03-week-3-navigation-state-management/`.

```text
flutter analyze
No issues found! (ran in 11.1s)

flutter test
+14: All tests passed!
```

### Proyek Praktikum 1

Working directory: `03-week-3-navigation-state-management/week3_navigation/`.

```text
dart format test/widget_test.dart
Formatted 1 file (1 changed).

flutter analyze
No issues found! (ran in 35.2s)

flutter test
Home, detail, back, dan akses path detail langsung
+1: All tests passed!
```

Jumlah akhir adalah **15 test dari dua proyek**, bukan 15 test pada satu kali
perintah `flutter test`. Pengujian path langsung pada proyek navigasi memakai
router.go di widget test; ini tidak mengklaim pengujian cold-start deep link
Android/iOS ataupun seluruh perilaku history browser.

## Bukti screenshot

| Step laporan | Berkas dalam `screenshots/` | Isi |
| --- | --- | --- |
| 2 | `instalasi praktikum 1.png` | Struktur folder lib proyek navigasi |
| 2 | `Aplikasi multi-page dengan GoRouter.png` | Home berisi sepuluh item |
| 3 | `instalasai praktikum 2.png` | Instalasi praktikum Riverpod |
| 3 | `Aplikasi ToDo dengan Riverpod.png` | Tugas PemMob ditandai selesai |
| 4 | `praktikum 3.1.png` | Produk success |
| 4 | `praktikum 3.2.png` | Produk error dan tombol retry |
| 5 | `refactoring-05-statistik-loading.png` | Spinner statistik |
| 5 | `refactoring-statistik-error.png` | Error statistik dan tombol Coba lagi |
| 5 | `refactoring-06-statistik-sukses.png` | Tiga statistik simulasi |
| 6 | `refactoring-01-daftar-kosong.png` | Empty state ToDo |
| 6 | `refactoring-02-tambah-tugas.png` | Dialog input judul |
| 6 | `refactoring-03-daftar-tugas.png` | Tiga tugas, satu selesai |
| 6 | `refactoring-04-filter-belum-selesai.png` | Filter menyembunyikan tugas selesai |
| 6 | `refactoring-07-state-setelah-navigasi.png` | Tugas dan filter bertahan setelah kembali |

Screenshot refactoring berasal dari build web aplikasi yang dijalankan di
Chrome pada sesi pengambilan screenshot sebelumnya. File gambar diperiksa
secara visual. Gambar statistik digunakan pada step 5 sebagai bukti hasil AI
Challenge yang sudah terintegrasi, bukan diklaim sebagai tampilan sebelum refactoring.

## Catatan penggunaan AI

Pembuatan statistik, refactoring, screenshot browser terotomasi, penyusunan
laporan, dan pembaruan test navigasi dibantu AI dalam riwayat pekerjaan ini.
Dokumentasi membedakan hasil aktual dari kesimpulan konseptual dan tidak
menyatakan demo mahasiswa telah dilaksanakan. Jawaban refleksi merujuk pada
implementasi yang tersedia dan perlu dipahami oleh mahasiswa saat presentasi.
