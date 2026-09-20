# 04 — Hasil testing

## Lingkungan dan direktori

- Tanggal verifikasi ulang: 18 September 2026.
- Platform: Windows, PowerShell.
- Flutter 3.47.1 stable; Dart 3.13.1 (berdasarkan `flutter --version` pada sesi implementasi).
- Dependensi proyek: `flutter_riverpod: ^3.4.3`.
- Working directory: `03-week-3-navigation-state-management/week3_todo`.

## Perintah

```powershell
flutter analyze; if ($?) { flutter test }
```

Analyzer dijalankan terlebih dahulu; test dijalankan setelah analyzer berhasil. Kedua perintah benar-benar dijalankan ulang setelah audit sumber.

## Output analyzer

```text
Analyzing week3_todo...
No issues found! (ran in 3.7s)
```

## Output test (path absolut dipendekkan menjadi path relatif)

```text
00:00 +0: loading test/stats_notifier_test.dart
00:00 +0: test/stats_notifier_test.dart: loading menunggu delay 2 detik lalu menghasilkan 3 statistik
00:00 +1: test/widget_test.dart: StatsPage menampilkan loading, error, retry, dan tiga item
00:00 +2: test/widget_test.dart: StatsPage menampilkan loading, error, retry, dan tiga item
00:00 +3: test/widget_test.dart: StatsPage menampilkan loading, error, retry, dan tiga item
00:00 +4: test/widget_test.dart: StatsPage menampilkan loading, error, retry, dan tiga item
00:00 +5: test/widget_test.dart: StatsPage menampilkan loading, error, retry, dan tiga item
00:00 +6: test/widget_test.dart: StatsPage menampilkan loading, error, retry, dan tiga item
00:00 +7: All tests passed!
```

Reporter dapat menampilkan nama widget test yang sama saat penghitung meningkat karena file test berjalan bersamaan. Jumlah dan kasus sebenarnya diperiksa dari deklarasi test berikut.

## Cakupan tujuh test

| No. | Jenis | Kasus dan hasil |
| --- | --- | --- |
| 1 | Unit | State awal loading, durasi yang diminta 2 detik, kemudian tiga label dan nilai statistik yang benar; lulus |
| 2 | Unit | Random 0.0 menghasilkan exception dan AsyncError; lulus |
| 3 | Unit | Random 0.299999 menghasilkan exception dan AsyncError; lulus |
| 4 | Unit | Random 0.30 menghasilkan tiga data tanpa error; lulus |
| 5 | Unit | Random 0.999999 menghasilkan tiga data tanpa error; lulus |
| 6 | Unit | Percobaan pertama gagal, invalidate menampilkan loading, percobaan kedua sukses, jumlah percobaan dua; lulus |
| 7 | Widget | Spinner awal, pesan error, klik Coba lagi, spinner retry, lalu ListView berisi tiga ListTile; lulus |

## Interpretasi

- Analyzer tidak melaporkan warning, error, atau info.
- Semua test lulus; output test tidak menampilkan warning.
- Unit test menggunakan Completer/dependency injection untuk mengontrol penyelesaian request. Pemeriksaan durasi memastikan notifier meminta dua detik, bukan mengukur jam nyata.
- Widget test memakai timer default dua detik dengan waktu virtual Flutter test.
- Batas random membuktikan logika `< 0.30`; pengujian ini bukan pengukuran distribusi statistik dari ribuan request.
- Ini verifikasi otomatis, bukan klaim sudah melakukan demo manual atau build pada setiap platform.
