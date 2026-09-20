# 05 — Panduan menjelaskan kode saat demo

Nomor baris mengacu pada hasil implementasi saat audit. Baris kosong hanya memisahkan bagian; komentar menjelaskan maksud blok; kurung penutup menutup constructor, callback, collection, metode, atau class yang bersangkutan.

## 1. `lib/providers/stats_provider.dart`

| Baris | Penjelasan |
| --- | --- |
| 1–3 | `dart:math` menyediakan Random; flutter_riverpod menyediakan AsyncNotifier dan provider. |
| 5–11 | StatItem adalah model satu statistik. Constructor const memungkinkan objek konstan; label bertipe String dan value bertipe int, keduanya final sehingga tidak bisa ditugaskan ulang. |
| 13–19 | Provider global bertipe notifier StatsNotifier dan data List<StatItem>. Tear-off `StatsNotifier.new` menjadi factory. Callback retry mengembalikan null untuk menolak retry otomatis. |
| 21 | AsyncNotifier mengelola AsyncValue secara otomatis dari Future yang dikembalikan build. |
| 22–28 | Constructor menerima dua fungsi opsional untuk test. Operator `??` menggunakan implementasi default jika tidak diinjeksi. Initializer list mengisi field sebelum constructor selesai. |
| 30–31 | `_delay` menerima Duration dan mengembalikan Future<void>; `_randomValue` tidak menerima argumen dan mengembalikan double. Awalan `_` membatasi akses pada library Dart. |
| 33–34 | `_wait` meneruskan durasi ke Future.delayed; static karena tidak membutuhkan instance notifier. |
| 36–40 | Override build mengembalikan Future<List<StatItem>>. `await` menunggu dua detik tanpa memblokir thread UI. Selama menunggu, Riverpod menyajikan loading. |
| 42–45 | Random.nextDouble menghasilkan angka dari 0 inklusif sampai 1 eksklusif. Nilai di bawah 0.30 memicu exception, yang menjadi AsyncError. |
| 47–52 | Mengembalikan const list tiga StatItem; label dan nilainya adalah data simulasi. List dan objek di dalamnya immutable. |
| 53–54 | Menutup build dan class. |

## 2. `lib/pages/stats_page.dart`

| Baris | Penjelasan |
| --- | --- |
| 1–4 | Mengimpor widget Material, integrasi Riverpod, serta provider statistik. |
| 6–8 | ConsumerWidget menyediakan ref di build; constructor const meneruskan key ke superclass. |
| 10–13 | build menerima context dan WidgetRef. watch berlangganan state; perubahan provider membangun ulang UI. |
| 15–17 | Scaffold menyediakan struktur halaman, AppBar judul Statistik, dan body berdasarkan AsyncValue.when. |
| 18–20 | Refresh tetap menampilkan spinner. Center memusatkan CircularProgressIndicator. |
| 21–28 | Callback error menerima error dan stackTrace. Error ditampilkan sebagai teks di tengah dengan padding 24; Column memakai tinggi minimum. Stack trace tersedia tetapi tidak ditampilkan ke pengguna. |
| 29–32 | SizedBox memberi jarak 16. FilledButton menginvalidasi provider saat ditekan; teks tombol Coba lagi. |
| 33–37 | Menutup tombol, children, Column, Padding, dan Center cabang error. |
| 38–42 | Callback data menerima list; ListView.builder membuat baris sesuai kebutuhan dengan jumlah items.length. Index mengambil satu item. |
| 43–46 | ListTile menampilkan label sebagai title dan nilai yang diubah menjadi String melalui interpolasi pada trailing. |
| 47–52 | Menutup itemBuilder, ListView, when, Scaffold, build, dan class. |

## 3. `lib/main.dart`

| Baris | Penjelasan |
| --- | --- |
| 1–4 | Import Flutter, Riverpod, dan halaman awal. |
| 6–9 | Entry point menjalankan MyApp dalam ProviderScope, tempat penyimpanan state Riverpod. |
| 11–15 | MyApp tidak memiliki state lokal; constructor const dan override build mengikuti kontrak StatelessWidget. |
| 16–20 | MaterialApp mengatur judul, tema teal Material 3, serta StatsPage sebagai home. |
| 21–23 | Menutup MaterialApp, build, dan class. |

## 4. `test/stats_notifier_test.dart`

| Baris | Penjelasan |
| --- | --- |
| 1–5 | Completer berasal dari dart:async; import lain menyediakan container, assertion test, dan kode yang diuji. |
| 7–15 | main mendaftarkan test. Helper membuat container dengan override notifier; addTearDown menjamin dispose setelah test sehingga state terisolasi. |
| 17–31 | Kasus pertama menahan delay dengan Completer. Fungsi delay merekam Duration, random 0.8 menjamin sukses. |
| 33–37 | Membaca provider memulai build; assertion memeriksa AsyncLoading dan durasi dua detik. |
| 39–47 | complete membuka penahan request; await provider.future mengambil data; assertion membandingkan semua label, nilai, dan AsyncData. |
| 48–49 | Menutup callback dan pendaftaran test pertama. |
| 51–56 | Loop mendaftarkan empat test terpisah pada nilai batas. Delay async kosong mempercepat unit test. |
| 58–66 | Untuk nilai di bawah 0.30, expectLater menunggu exception lalu memeriksa AsyncError. |
| 67–72 | Untuk nilai mulai 0.30, periksa panjang list tiga dan tidak ada error; tutup cabang dan loop test. |
| 74–85 | Kasus retry menghitung request. Request kedua ditahan retryGate; angka random pertama 0.1 dan berikutnya 0.9. |
| 87–91 | Buktikan request pertama gagal dan state berisi error. |
| 93–99 | Invalidate seperti tombol UI, baca untuk memulai request baru, periksa loading, lepaskan gate, lalu periksa sukses dan tepat dua percobaan. |
| 100–101 | Menutup test terakhir dan main. |

## 5. `test/widget_test.dart`

| Baris | Penjelasan |
| --- | --- |
| 1–5 | Mengimpor widget, ProviderScope, API widget test, aplikasi, dan notifier. |
| 7–11 | Daftarkan testWidgets dengan WidgetTester; attempts menentukan hasil random tiap request. |
| 12–22 | pumpWidget merender aplikasi dengan provider override: notifier asli tetap menjalankan delay default, tetapi random dibuat gagal lalu sukses. |
| 23 | Memastikan spinner pertama terlihat. |
| 25–28 | pump dua detik memajukan timer virtual; pump berikutnya merender perubahan; pastikan pesan error terlihat. |
| 29–31 | Tap tombol retry, render, dan pastikan spinner muncul lagi. |
| 33–37 | Majukan dua detik, render hasil, lalu periksa satu ListView, tiga ListTile, dan label Total pengguna. |
| 38–39 | Menutup test dan main. |

## Urutan demo

1. Buka README bagian 5 dan jelaskan tujuan serta lokasi prompt/output AI.
2. Buka notifier: jelaskan generic, immutable data, delay, random 30%, dan retry manual.
3. Buka StatsPage: jelaskan watch di build, tiga cabang when, dan invalidate di tombol.
4. Jalankan `flutter run` dari `week3_todo`; amati hasil aktual. Request boleh berhasil atau gagal karena random.
5. Jalankan `flutter test` untuk memperlihatkan error dan retry yang deterministik, lalu `flutter analyze` untuk pemeriksaan statis.
6. Jelaskan mengapa test counter diganti dan mengapa audit lanjutan tidak memerlukan perubahan Dart.
7. Pastikan dapat menjelaskan setiap ekspresi di tabel, bukan hanya menghafal kesimpulan lulus.

Panduan ini disiapkan untuk belajar; kemampuan menjelaskan kode harus dibuktikan saat demo sesungguhnya.
