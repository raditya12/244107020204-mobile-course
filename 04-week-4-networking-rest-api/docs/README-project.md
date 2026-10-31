# Week 4 — Networking REST API & AI Challenge

Aplikasi Flutter menggunakan Dio dan flutter_riverpod untuk JSONPlaceholder.
Ketuk post pada halaman **Posts Paged** untuk membuka komentarnya.

## Alur fitur komentar

`CommentsPage → commentsProvider(postId) → CommentRepository → Dio`

- `lib/data/models/comment.dart`: model immutable dengan parsing aman.
- `lib/data/repositories/comment_repository.dart`: `fetchComments(int postId)`
  memanggil `GET /comments?postId={id}` dan memvalidasi bentuk respons.
- `lib/data/comment_providers.dart`: AsyncNotifierProvider family per postId.
  Future gagal menjadi AsyncError; retry melalui invalidasi provider.
- `lib/data/api_client.dart`: base URL dan connect/send/receive timeout 10 detik.
  Batas ini berlaku per fase Dio, bukan deadline total request 10 detik.
- `lib/data/providers.dart`: dependency client dan pesan error bahasa Indonesia.
- `lib/pages/comments_page.dart`: loading, data, daftar kosong, error, dan retry.

## AI Verification Checklist

| Pemeriksaan | Temuan dan hasil |
| --- | --- |
| Apakah UI memanggil Dio langsung? | Tidak. Halaman membaca provider; hanya repository menjalankan request. |
| Apakah fromJson aman null? | Ya. Field hilang/null/tipe keliru memakai ID `0` atau teks `''`. Cast hanya dilakukan setelah pemeriksaan tipe. |
| Apakah tipe error dipetakan? | Ya. Connection/send/receive/transform timeout, connectionError, badResponse, badCertificate, cancel, unknown; HTTP 404 dan 500 memiliki pesan khusus. |
| Apakah baseUrl/timeout terpusat? | Ya, di `createDio()`. `sendTimeout` ditambahkan saat review; repository tidak menduplikasi konfigurasi. |
| Apakah test menguji field hilang? | Ya, `Comment.fromJson({})` memeriksa kelima field. Edge case tambahan: null/tipe salah dan respons rusak. |
| Apakah analyze dan test lolos? | Ya. Analyze akhir: **No issues found**; test: **32 lulus**. Analyze pertama menemukan transformTimeout yang belum dipetakan, lalu diperbaiki. |

## Menjalankan verifikasi

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

Test memakai fake adapter/repository, tidak bergantung pada koneksi atau kondisi
server publik. Timeout diuji dengan simulasi exception dan pemeriksaan konfigurasi,
bukan menunggu jaringan selama 10 detik.

## Dokumentasi tugas

- [Prompt](docs/prompt.md)
- [Output awal AI sebelum review](docs/output-awal.md)
- [Perbaikan dan panduan penjelasan demo](docs/perbaikan.md)
- [Hasil testing](docs/hasil-testing.md)

Edge case tambahan pada sesi ini dibuat oleh AI assistant. Untuk memenuhi bagian
“tambahkan edge case sendiri”, mahasiswa perlu menambahkan kasus pilihannya sendiri
dan mencatat hasil verifikasinya. Pengujian runtime Chrome dengan API sungguhan,
simulasi HTTP 500, dan retry telah dilakukan. Laporan **Step 6** beserta screenshot
tersedia pada [README minggu 4](../README.md#step-6--ai-challenge).
