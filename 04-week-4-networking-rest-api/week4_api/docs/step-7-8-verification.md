# Verifikasi lanjutan Step 7–8

Tanggal: 29 September 2026.

## Perubahan

- Ekstrak PostTile dan network_errors.dart, gunakan pada paged/non-paged.
- GoRouter `/post/:id`: objek Post dari list atau fetchPost melalui repository.
- Route `/post/:id/comments` menghubungkan fitur sebelumnya.
- Guard request pertama, ref.mounted, UI retry pagination dan empty state.
- Delapan test tambahan di post_test.dart; total akhir 40.

## Hasil aktual

```text
flutter analyze
No issues found! (ran in 2.9s)

flutter test
00:01 +40: All tests passed!

flutter build web
Built build/web
```

Percobaan awal: tiga lint (kurung kurawal dan super parameter), satu assertion
route gagal karena memeriksa routeInformationProvider setelah push. Perbaikan:
gunakan GoRouterState dari halaman detail dan aktifkan URL reflection pada router
aplikasi. Setelah koreksi, seluruh verifikasi di atas berhasil.

## Runtime browser

Script `capture-step-7-8.cjs` menjalankan server build lokal dan Chrome headless.
Membutuhkan Node.js, package playwright, Chrome, serta `flutter build web`.
Jalankan `node docs/capture-step-7-8.cjs` dengan playwright tersedia di resolusi
module Node (pada sesi ini dependency berada di direktori temporary, melalui NODE_PATH).

```text
API 200 /posts?_page=1&_limit=10
PASS cached detail: no GET /posts/1
API 200 /posts/2
API 200 /posts?_page=1&_limit=10
API 500 /posts?_page=2&_limit=10 [simulasi]
API 200 /posts?_page=2&_limit=10 [retry ke API nyata]
API 200 /posts?_page=3&_limit=10 ... /posts?_page=11&_limit=10
API 200 /posts?_page=1&_limit=10 [simulasi array kosong]
PASS: detail cache/deep link, loading, pagination error/retry/end, empty
```

Screenshot runtime tersimpan di folder screenshots minggu 4 dengan prefix
step-7 dan step-8. Respons sukses berasal dari API sungguhan; error 500 dan empty
state diintersepsi browser. Loading ditahan sementara agar spinner tertangkap.

Perbaikan script capture: reload penuh untuk deep link agar semantics Flutter
diaktifkan dari awal; spinner tidak memiliki role progressbar pada DOM sehingga
request ditahan dengan gate; teks footer error tidak muncul dalam semantics
walaupun terlihat di canvas, sehingga script menunggu tombol retry dan hasil
gambar diperiksa secara visual. Ini perubahan otomasi, bukan hasil test aplikasi
yang disembunyikan.
