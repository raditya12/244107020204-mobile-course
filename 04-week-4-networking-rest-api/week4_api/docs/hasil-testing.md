# Hasil verifikasi — 29 September 2026

Perintah dijalankan dari direktori `week4_api`.

## 1. flutter analyze — percobaan pertama

Exit code: 1.

```text
error - The type 'DioExceptionType' isn't exhaustively matched by the switch cases
since it doesn't match the pattern 'DioExceptionType.transformTimeout'.
non_exhaustive_switch_statement
1 issue found. (ran in 20.6s)
```

Koreksi: tambahkan transformTimeout pada helper dan test pesan timeout.

## 2. Formatting

`dart format` dijalankan pada file implementasi yang disentuh dan folder test.

```text
Formatted 12 files (11 changed) in 0.08 seconds.
```

## 3. flutter test

Exit code: 0. Ringkasan output aktual:

```text
00:01 +32: All tests passed!
```

| File | Jumlah | Cakupan |
| --- | ---: | --- |
| comment_test.dart | 3 | Field hilang, null/tipe salah, field valid |
| comment_repository_test.dart | 18 | URL/query/timeout, array kosong, 4 respons rusak, 9 enum Dio ke AsyncError, HTTP 404/500, family |
| friendly_error_message_test.dart | 10 | Pesan untuk 9 enum Dio dan fallback non-Dio |
| widget_test.dart | 1 | Error koneksi tampil, retry berhasil, empty state |

Semua pengujian berjalan tanpa jaringan. Timeout disimulasikan di adapter;
konfigurasi connect/send/receive timeout juga diperiksa pada request Dio.

## 4. flutter analyze — setelah perbaikan

Exit code: 0. Output aktual:

```text
Analyzing week4_api...
No issues found! (ran in 2.5s)
```

## 5. Review sumber

Halaman UI hanya mengakses provider. Konfigurasi URL dan timeout berada di
api_client.dart. Request comments berada di CommentRepository. Tidak ada
request Dio langsung pada halaman UI.

## 6. Build web dan screenshot runtime

`flutter build web` berhasil: `Built build/web` (43,1 detik).
Build disajikan melalui server lokal port 8765 dan dijalankan di Chrome headless
dengan Playwright, viewport 1100 × 850.

Log respons saat pengambilan screenshot:

```text
API 200 https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10
API 200 https://jsonplaceholder.typicode.com/comments?postId=1
API 500 https://jsonplaceholder.typicode.com/comments?postId=1
API 200 https://jsonplaceholder.typicode.com/comments?postId=1
RETRY SUCCESS: live JSONPlaceholder comments displayed
```

HTTP 500 merupakan simulasi intersepsi respons browser. Respons 200 berasal dari
API sungguhan. Screenshot tersimpan di `../../screenshots/step-6-*.png` dan
ditampilkan dalam [laporan Step 6](../../README.md#step-6--ai-challenge).

Capture pertama menunggu teks komentar dengan pencocokan exact, tetapi Flutter
menggabungkan teks ListTile pada semantics sehingga locator timeout. Locator
diubah menjadi pencocokan sebagian; alur berikutnya berhasil. Capture error
diulang setelah menunggu animasi navigasi selesai agar gambar stabil.

Belum dilakukan: demo pada perangkat Android fisik.
