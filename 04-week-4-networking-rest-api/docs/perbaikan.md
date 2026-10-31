# Review dan perbaikan logic

## Temuan → koreksi

1. Output awal memakai `(response.data ?? []).whereType<...>()`. Respons null
   dianggap kosong dan elemen rusak dibuang diam-diam. Versi akhir memeriksa
   array dan setiap objek; respons rusak menghasilkan FormatException sehingga
   pengguna menerima pesan error. Array `[]` tetap hasil valid.
2. Client awal hanya memiliki connect/receive timeout. Tambahkan sendTimeout
   10 detik di client bersama. Dio ditutup ketika provider di-dispose.
3. Helper awal memakai default untuk sebagian enum dan memperlihatkan detail
   exception non-Dio. Versi akhir memetakan setiap enum secara eksplisit,
   menambahkan pesan HTTP 500, format data, dan fallback tanpa detail internal.
4. Analyze pertama gagal karena Dio 5.11.1 juga mempunyai transformTimeout.
   Tambahkan tipe tersebut ke kelompok timeout dan test pemetaan. Analyze ulang
   tidak menemukan masalah.
5. Test awal hanya field hilang. Tambahkan null/tipe salah, data valid,
   kontrak request, bentuk respons, semua enum Dio, HTTP 404/500, AsyncError,
   provider family, dan retry UI.
6. Test widget bawaan masih menguji counter. Ganti dengan skenario error →
   tombol coba lagi → daftar kosong pada CommentsPage, tanpa HTTP sungguhan.
7. Hapus import PostListPage yang tidak digunakan di main.dart.

## Panduan menjelaskan kode saat demo

- Model: `final` membuat field immutable; constructor `const` mendukung nilai
  konstan; factory membaca JSON. `is` memastikan tipe sebelum `as`, sehingga
  field hilang/null tidak menyebabkan cast error. String ID tidak dikonversi;
  tipe yang tidak sesuai kontrak memakai default.
- Repository: constructor injection memungkinkan client diganti di test.
  `queryParameters` membentuk query URL tanpa penyambungan string manual.
  `await` menunggu respons; pemeriksaan list/map menjaga bentuk payload.
  Tidak menangkap error di sini agar penyebab dan stack trace tetap diteruskan.
- Provider repository: `ref.watch(dioProvider)` memperoleh client bersama.
  Family memakai postId sebagai kunci state. `autoDispose` membersihkan state
  setelah tidak diamati. `build` meneruskan Future; Riverpod mengelola
  AsyncLoading/AsyncData/AsyncError. Retry otomatis dimatikan agar error segera
  terlihat dan percobaan ulang dikendalikan tombol pengguna.
- UI: `ref.watch` memperbarui tampilan saat state berubah; `when` memilih
  loading/error/data. `ref.invalidate` membuat request baru setelah retry.
  Navigasi dari post hanya membawa ID, bukan menjalankan HTTP dari widget.
- Error helper: switch eksplisit membantu analyzer mendeteksi penambahan enum;
  status HTTP dibaca dari response untuk pesan 404/500.
- Test: fake adapter mengembalikan JSON/status atau melempar DioException;
  Dio asli tetap memvalidasi status dan decoding JSON. ProviderContainer
  mengisolasi state; listener menjaga autoDispose aktif selama pengujian.

## Batas verifikasi

Kasus tambahan di atas dibuat AI pada sesi ini, bukan klaim pekerjaan mandiri
mahasiswa. Mahasiswa perlu memahami kode dan menambahkan edge case sendiri.
Runtime Chrome sudah diuji dengan API nyata, simulasi 500, dan retry; screenshot
ada di folder screenshots minggu 4. Timeout 10 detik adalah konfigurasi per fase
koneksi/kirim/terima, bukan jaminan deadline total request.
