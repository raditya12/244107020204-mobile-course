# Hasil testing — 4 Oktober 2026

## Pemeriksaan kode

```text
flutter analyze
No issues found!

flutter test
All tests passed! (13 tests)

flutter build web
Built build/web
```

## Pengujian aplikasi aktual

Perintah: `python tool/capture_screenshots.py`, setelah hasil build dilayani melalui `http://127.0.0.1:8765`.

```text
result: PASS
screenshots: 9
page_errors: []
```

| Skenario | Hasil aktual |
|---|---|
| Buka aplikasi tanpa catatan | Pesan kosong tampil |
| Ambil bacaan online | 100 bacaan masuk cache |
| Buat dua catatan saat forceOffline aktif | Judul dan isi dapat dibaca di detail; badge = 2 |
| Blokir API dan reload | Catatan, badge = 2, dan 100 bacaan cache tetap tersedia |
| Buka URL detail dan reload langsung | Detail tetap membaca catatan lokal |
| Tambah, edit, hapus catatan sementara saat offline | Berhasil; badge kembali ke 2 |
| Online dan jalankan sync | Badge berubah 2 → 0 |
| Aktifkan tema gelap dan reload | Switch tetap aktif dan tema tetap gelap |

Browser mencatat request API gagal saat endpoint sengaja diblokir. Ini bagian dari pengujian offline, bukan page error JavaScript.

Screenshot berada di `../screenshots/` dan ditampilkan dalam README. Pengujian otomatis menggunakan Chrome dan SQLite Web. Pengguna kemudian memberikan lima screenshot pengujian manual HP Android, termasuk mode pesawat, yang dirangkum di bawah.

## Cakupan test otomatis

- `note_test.dart`: mapping model, serialisasi, provider sukses/error dengan repository palsu.
- `offline_storage_test.dart`: CRUD SQLite in-memory, baca berdasarkan ID, dirty sebelum/sesudah sync, edit selama upload, upload gagal, cache lokal.
- `detail_and_cache_test.dart`: URL detail tanpa mengambil daftar, catatan tidak ditemukan, cache muncul sebelum API selesai, mode offline tidak menjadwalkan API.
- `widget_test.dart`: kondisi kosong dan toggle offline tetap memungkinkan membuka formulir tambah.

## Verifikasi build Android berikutnya

HP `2201117PG` (Android 13) terdeteksi pada sesi perbaikan build. Error sebelumnya menunjukkan incremental cache Kotlin untuk `shared_preferences_android` gagal ditutup dan storage sudah terdaftar.

Perbaikan: menambahkan `kotlin.incremental=false` pada `android/gradle.properties`, menghentikan daemon Gradle, lalu menjalankan `flutter clean` dan `flutter pub get`.

```text
flutter build apk --debug
Built build/app/outputs/flutter-apk/app-debug.apk

Percobaan flutter run dengan APK hasil build:
INSTALL_FAILED_USER_RESTRICTED: Install canceled by user
```

Build Android berhasil. Percobaan instalasi awal ditolak perangkat. Pengguna kemudian berhasil memasang aplikasi dan memberikan screenshot pengujian HP. Warning native access Java masih muncul, tetapi tidak menghalangi build.

## Pengujian manual HP Android

Observasi berdasarkan screenshot yang diberikan pengguna, bukan sesi otomatis:

| File | Hasil yang terlihat |
|---|---|
| `09-mobile-online-cache.png.jpg` | Mode online, daftar catatan kosong, badge 0, 100 bacaan cache |
| `10-mobile-mode-pesawat-dirty.png.jpg` | Ikon pesawat, toggle offline aktif, tombol sync nonaktif, badge 0, 100 bacaan cache |
| `11-mobile-offline-setelah-buka-ulang.png.jpg` | Ikon pesawat, catatan “belajar penyimpanan lokal”, isi “offline”, badge 1 |
| `12-mobile-detail-offline.png.jpg` | Detail catatan dan status belum tersinkron terbaca dalam mode pesawat |
| `13-mobile-setelah-sync.png.jpg` | Mode online, badge 0, daftar catatan kosong, 100 bacaan cache |

Bukti mobile menunjukkan cache dan catatan dapat dibaca dalam mode pesawat. Screenshot terakhir belum menunjukkan catatan yang berstatus tersinkron karena daftar kosong. Karena itu, angka 0 pada mobile tidak dipakai sebagai bukti tunggal keberhasilan sync. Perubahan status catatan sebelum/sesudah sync sudah dibuktikan pada pengujian Chrome.

Screenshot pengaturan tema mobile belum diberikan; bukti persistensi tema menggunakan hasil pengujian Chrome. Kelima gambar mobile ditampilkan dalam README dengan nama file aslinya.

## Mengulang screenshot web

```bash
flutter build web
python -m http.server 8765 --bind 127.0.0.1 --directory build/web
```

Di terminal lain pada folder project yang sama:

```bash
python -m pip install playwright
python tool/capture_screenshots.py
```

Script menggunakan Chrome yang terpasang dan context browser baru. Data pengujian tidak memakai profil browser pribadi. Screenshot ditulis ulang dengan hasil sesi terbaru.
