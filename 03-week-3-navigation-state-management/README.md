# Laporan Praktikum Jobsheet 3 — Navigation & State Management

| Identitas | Keterangan |
| --- | --- |
| Nama | Raditya Riefki |
| NIM | 244107020204 |
| Mata kuliah | Pemrograman Mobile |
| Materi | Navigasi, Riverpod, AsyncValue, refactoring, dan testing |
| Sumber | [Codelab Minggu 3 JTI Polinema](https://jti-polinema.github.io/flutter-codelab/03-minggu-3-navigation-state-management/index.html#0) |

Laporan ini merangkum step 1–7: persiapan, navigasi GoRouter, ToDo Riverpod,
state asinkron, AI Challenge, refactoring/testing, serta tugas dan refleksi.
Screenshot praktikum awal menggunakan berkas yang telah disimpan sesuai nama
praktikum. Screenshot berawalan `refactoring-` menunjukkan aplikasi akhir
yang dijalankan di Chrome dengan viewport 430 × 932 dan hasil PNG 860 × 1864.

## Daftar isi

1. [Pendahuluan dan persiapan](#step-1--pendahuluan-dan-persiapan)
2. [Navigasi dengan GoRouter](#step-2--navigasi-dengan-gorouter)
3. [State management dengan Riverpod](#step-3--state-management-dengan-riverpod)
4. [State asinkron dengan AsyncValue](#step-4--state-asinkron-dengan-asyncvalue)
5. [AI Challenge dan verifikasi](#step-5--ai-challenge-dan-verifikasi)
6. [Refactoring dan testing](#step-6--refactoring-dan-testing)
7. [Tugas dan refleksi](#step-7--tugas-dan-refleksi)

## Step 1 — Pendahuluan dan persiapan

### Tujuan

1. Memahami route dan stack navigasi serta perbedaan Navigator 1.0 dan GoRouter.
2. Menerapkan navigasi antarhalaman, path parameter, dan akses path langsung.
3. Memisahkan state dari UI menggunakan Riverpod agar konsisten antarhalaman.
4. Menampilkan loading, error, dan success menggunakan AsyncValue.
5. Memverifikasi implementasi melalui analyzer, unit test, dan widget test.

### Persiapan dan teknologi

Perangkat kerja menggunakan Windows, Flutter SDK, Dart, VS Code, Git, dan
repository portfolio GitHub. Screenshot aplikasi pada laporan diambil dari
Flutter Web/Chrome; bukan dari emulator Android.

| Teknologi | Peran |
| --- | --- |
| Flutter dan Dart | Implementasi UI deklaratif dan logika aplikasi |
| Material 3 | Komponen tampilan, dialog, checkbox, dan NavigationBar |
| `go_router` 18.0.1 | Konfigurasi route dan perpindahan halaman |
| `flutter_riverpod` 3.4.3 | Notifier, Provider turunan, dan AsyncNotifier |
| `flutter_test` | Unit test serta widget test |
| Git dan GitHub | Version control dan pengumpulan portfolio |

Terdapat proyek awal `week3_navigation` untuk Praktikum 1 dan package
`week3_todo` untuk Praktikum 2–3 serta mini project. Setelah step 6, proyek
ToDo ditempatkan langsung dalam folder minggu ke-3 sesuai struktur tugas.

**Hasil:** kebutuhan lingkungan dan pembagian proyek telah tersedia.
Dokumentasi struktur proyek dan pemasangan dependensi ditampilkan pada step 2
dan step 3.

## Step 2 — Navigasi dengan GoRouter

### Dasar teori

Navigator 1.0 menggunakan `Navigator.push` dan `Navigator.pop` untuk
menambah atau menghapus route pada stack. GoRouter mendefinisikan hubungan
path dan halaman secara deklaratif sehingga route lebih mudah dikelola dan
dapat diakses berdasarkan URL.

### Praktikum 1 — Aplikasi multi-page

Perintah pembuatan proyek pada praktikum awal:

```sh
flutter create week3_navigation
cd week3_navigation
flutter pub add go_router
```

![Struktur folder Praktikum 1](screenshots/instalasi%20praktikum%201.png)

*Gambar 1. Struktur `lib/` Praktikum 1: main.dart, home_page.dart, dan
detail_page.dart. Nama berkas arsip adalah “instalasi praktikum 1.png”.*

Implementasi berada di [week3_navigation/lib](week3_navigation/lib):

- `main.dart` menggunakan `MaterialApp.router` dan konfigurasi GoRouter.
- `home_page.dart` menampilkan sepuluh item dengan `ListView.builder`.
- `detail_page.dart` menerima ID dari `state.pathParameters['id']`.
- Route `/` menampilkan Home; child route `detail/:id` menghasilkan path
  seperti `/detail/3`.
- Ketika item dipilih, `context.go('/detail/${index + 1}')` menampilkan detail.
  Karena detail merupakan child route Home, konfigurasi path detail ini
  membentuk stack Home–Detail sehingga back dapat kembali ke Home.

![Home dengan sepuluh item](screenshots/Aplikasi%20multi-page%20dengan%20GoRouter.png)

*Gambar 2. Hasil Praktikum 1: halaman Home menampilkan Item 1–10.*

**Hasil dan verifikasi:** pengujian di
[week3_navigation/test/widget_test.dart](week3_navigation/test/widget_test.dart)
memeriksa pemilihan Item 3, isi Detail 3, tombol back sistem, serta navigasi
langsung ke `/detail/9` melalui router tanpa memilih item. Test bawaan counter
diganti karena tidak lagi sesuai dengan fungsi aplikasi. Screenshot yang
tersedia untuk praktikum ini menunjukkan Home; verifikasi detail/back
dibuktikan melalui widget test.

## Step 3 — State management dengan Riverpod

### Dasar teori

`setState` sesuai untuk state lokal. Ketika data digunakan beberapa halaman,
state sebaiknya dipisahkan dari widget agar tidak perlu dikirim berulang
melalui constructor dan tidak hilang hanya karena suatu halaman ditutup.
Riverpod menyediakan container state melalui `ProviderScope`.

### Praktikum 2 — Aplikasi ToDo

Perintah pembuatan proyek pada praktikum awal:

```sh
flutter create week3_todo
cd week3_todo
flutter pub add flutter_riverpod
```

![Instalasi Riverpod pada Praktikum 2](screenshots/instalasai%20praktikum%202.png)

*Gambar 3. Dokumentasi instalasi Praktikum 2; nama berkas mengikuti arsip asli.*

Langkah implementasi:

1. Membungkus root aplikasi dengan `ProviderScope`.
2. Membuat model `Todo` dengan judul, status selesai, dan `copyWith`.
3. Membuat `TodoListNotifier` dan `todoListProvider` untuk tambah, toggle, hapus.
4. Menggunakan `ConsumerWidget` dan `ref.watch` untuk membangun daftar.
5. Memanggil method notifier melalui `ref.read` pada callback pengguna.
6. Mengganti list dengan list baru saat state berubah, bukan `state.add()`.

![ToDo Riverpod dengan tugas selesai](screenshots/Aplikasi%20ToDo%20dengan%20Riverpod.png)

*Gambar 4. Tugas “PemMob” ditandai selesai: checkbox aktif dan teks tercoret.*

**Hasil:** UI bereaksi terhadap perubahan provider. Tugas dapat ditambah melalui
dialog, ditandai selesai, dan dihapus. Pada versi akhir, model ditambah ID
stabil agar aksi tetap tepat ketika daftar difilter; rincian ada pada step 6.

## Step 4 — State asinkron dengan AsyncValue

### Praktikum 3 — Uji tiga kondisi

Implementasi latihan disimpan di
[products_provider.dart](lib/providers/products_provider.dart) dan
[product_page.dart](lib/pages/product_page.dart).

| Kondisi | Implementasi | Respons UI |
| --- | --- | --- |
| Loading | `build()` menunggu dua detik | `CircularProgressIndicator` |
| Error | Exception pada simulasi pengambilan data | Pesan gagal dan tombol Coba lagi |
| Success | Future menghasilkan daftar produk | Keyboard, Mouse, dan Monitor |
| Retry | `ref.invalidate(productsProvider)` | Provider menjalankan pengambilan data ulang |

`ProductsNotifier.refresh()` menggunakan `AsyncLoading` kemudian
`AsyncValue.guard` agar exception dari proses refresh menjadi `AsyncError`.
UI memakai `when(loading: ..., error: ..., data: ...)`, sehingga setiap
kondisi memiliki tampilan yang jelas.

![Produk berhasil dimuat](screenshots/praktikum%203.1.png)

*Gambar 5. `praktikum 3.1.png` memperlihatkan state success berisi tiga produk.*

![Produk gagal dimuat dengan tombol retry](screenshots/praktikum%203.2.png)

*Gambar 6. `praktikum 3.2.png` memperlihatkan simulasi error “Gagal terhubung ke server”.*

Pada latihan error, `build()` sementara dibuat melempar exception. Pada kode
akhir produk, pengambilan data kembali menghasilkan daftar produk. Halaman
produk tersimpan sebagai hasil latihan; route mini project akhir menggunakan
daftar ToDo dan statistik. Bukti visual loading tersedia pada statistik di step 5.

### Refleksi stale data

Menampilkan data lama sambil memberi indikator refresh mempertahankan konteks
pengguna: daftar tetap dapat dibaca, posisi tidak terasa hilang, dan layar
tidak kosong ketika jaringan lambat. Pola ini berguna untuk katalog, berita,
dashboard, atau daftar tugas dengan koneksi tidak stabil. Data harus diberi
indikator sedang diperbarui atau informasi waktu pembaruan agar tidak disangka
paling baru. Untuk data kritis seperti saldo atau ketersediaan stok, keputusan
penting tetap perlu validasi terbaru. Pada latihan statistik ini dipilih
spinner saat retry (`skipLoadingOnRefresh: false`) agar transisi state mudah diamati.

## Step 5 — AI Challenge dan verifikasi

### Prompt dan hasil implementasi

Prompt meminta halaman `StatsPage` menggunakan `ConsumerWidget`, satu
`AsyncNotifierProvider`, delay dua detik, peluang gagal 30%, UI loading/error/
success dengan tiga item, tombol retry, unit test, serta komentar penjelas.

Hasil implementasi:

- [stats_provider.dart](lib/providers/stats_provider.dart): model `StatItem`,
  `StatsNotifier`, dan `statsProvider`.
- [stats_page.dart](lib/pages/stats_page.dart): tampilan tiga kondisi AsyncValue.
- [stats_notifier_test.dart](test/stats_notifier_test.dart): enam unit test.
- [widget_test.dart](test/widget_test.dart): satu widget test alur loading,
  error, retry, dan success.

Nilai statistik merupakan **data simulasi**, bukan perhitungan jumlah ToDo:
Total pengguna = 1200, Pengguna aktif = 850, Transaksi hari ini = 320.
Error terjadi saat angka acak `< 0.30`; peluang tersebut tidak menjamin tepat
tiga kegagalan dalam setiap sepuluh percobaan.

### Bukti tampilan statistik

| Loading | Error dan retry | Success |
| --- | --- | --- |
| ![Loading statistik](screenshots/refactoring-05-statistik-loading.png) | ![Error statistik](screenshots/refactoring-statistik-error.png) | ![Success statistik](screenshots/refactoring-06-statistik-sukses.png) |

*Gambar 7–9. StatsPage setelah diintegrasikan ke aplikasi akhir. Ketiga kondisi
diambil dari aplikasi yang berjalan; error berasal dari simulasi acak dan
diikuti retry hingga data berhasil ditampilkan.*

### Hasil AI Verification Checklist

| Pemeriksaan | Temuan |
| --- | --- |
| Immutable state | Properti model `final`, hasil statistik list konstan, perubahan ToDo membuat list baru |
| `watch` dan callback | UI berlangganan dalam `build`; callback ToDo memakai `read`, retry memakai `invalidate` |
| Tiga state AsyncValue | `when` menangani loading, error dengan retry, dan data |
| Tipe dan duplikasi | Generic notifier/data eksplisit; satu deklarasi `statsProvider` |
| API Riverpod | Menggunakan Notifier/AsyncNotifier dan ConsumerWidget, bukan pola StateNotifierProvider lama |
| Analyzer dan test | Verifikasi awal 7 test lulus; setelah refactoring menjadi 14 test pada aplikasi utama |

`ref.watch` juga tepat dipakai di dalam **Provider turunan** untuk menyatakan
dependensi reaktif; larangan pada checklist ditujukan pada pemakaian dalam
callback event. `ref.invalidate` pada retry tidak perlu dipaksakan menjadi
`ref.read` karena tujuannya membuang hasil dan menjalankan provider ulang.

### Perbaikan, keputusan teknis, dan arsip

Implementasi awal sudah memakai dependency injection untuk delay/angka acak,
list konstan, dan retry manual. Audit tidak menemukan kebutuhan migrasi API
atau perbaikan Dart pada tahap tersebut. Perubahan awal mencakup penggantian
test counter menjadi test statistik. Pada tahap refactoring, halaman awal
statistik kemudian diganti menjadi daftar ToDo dengan navigasi `/stats`,
sehingga seluruh fitur praktikum dapat diakses dalam satu aplikasi.

| Dokumen | Isi |
| --- | --- |
| [01-prompts.md](docs/ai-challenge/01-prompts.md) | Prompt dan instruksi verifikasi |
| [02-output-awal.md](docs/ai-challenge/02-output-awal.md) | Arsip keluaran awal AI |
| [03-perbaikan.md](docs/ai-challenge/03-perbaikan.md) | Riwayat perubahan dan audit |
| [04-testing.md](docs/ai-challenge/04-testing.md) | Hasil testing awal AI Challenge |
| [05-panduan-demo.md](docs/ai-challenge/05-panduan-demo.md) | Panduan penjelasan implementasi awal |
| [refactoring-testing.md](docs/refactoring-testing.md) | Perubahan dan hasil testing setelah refactoring |

Dokumen AI Challenge merupakan arsip sebelum pemindahan proyek. Rujukan folder
`week3_todo/` dan nomor baris pada panduan lama mengikuti kondisi saat itu;
sumber aplikasi terkini berada di `lib/` folder minggu ke-3.

## Step 6 — Refactoring dan testing

### Refactoring yang dilakukan

1. **Ekstraksi TodoTile.** [todo_tile.dart](lib/widgets/todo_tile.dart) menerima
   `Todo`, `onToggle`, dan `onDelete`. Widget tidak mengakses provider sehingga
   tampilan dan callback dapat diuji secara mandiri.
2. **Provider filter turunan.** `filteredTodosProvider` membaca
   `todoListProvider` dan `todoFilterProvider`. Switch mengatur apakah seluruh
   tugas atau hanya tugas belum selesai yang ditampilkan.
3. **ID stabil.** Toggle/hapus menggunakan ID tugas, bukan posisi pada daftar
   hasil filter. `copyWith` mempertahankan ID; ini mencegah perubahan pada
   tugas yang salah setelah sebagian item disembunyikan.
4. **Integrasi GoRouter.** [app_router.dart](lib/router/app_router.dart)
   mendefinisikan `/` dan `/stats`. `ShellRoute` menyediakan NavigationBar;
   push membuka statistik dan go mengembalikan pengguna ke daftar.
5. **State lintas halaman.** ProviderScope berada di atas MaterialApp.router,
   sehingga tugas serta filter tetap tersedia ketika halaman berubah.

| Daftar kosong | Dialog tambah | Daftar setelah ditambah |
| --- | --- | --- |
| ![Daftar kosong](screenshots/refactoring-01-daftar-kosong.png) | ![Dialog tambah tugas](screenshots/refactoring-02-tambah-tugas.png) | ![Daftar tugas dan status selesai](screenshots/refactoring-03-daftar-tugas.png) |

*Gambar 10–12. Alur menambahkan tugas dan menandai salah satu tugas selesai.*

| Filter belum selesai | Kembali dari statistik |
| --- | --- |
| ![Filter tugas aktif](screenshots/refactoring-04-filter-belum-selesai.png) | ![State bertahan setelah navigasi](screenshots/refactoring-07-state-setelah-navigasi.png) |

*Gambar 13–14. Tugas selesai disembunyikan oleh filter. Setelah berpindah ke
statistik lalu kembali, isi daftar dan pilihan filter tetap sama.*

### Pengujian

Widget test menambahkan “Kerjakan PR minggu 3” melalui tombol tambah dan dialog,
kemudian memeriksa bahwa judul tampil. Test tambahan memeriksa toggle/hapus
pada daftar terfilter, state lama tidak dimutasi, ID tidak dipakai ulang,
validasi judul, navigasi/back, dan akses route `/stats` secara langsung.

| Lokasi test | Jumlah | Cakupan |
| --- | ---: | --- |
| `test/stats_notifier_test.dart` | 6 | Delay, data, batas peluang gagal, retry |
| `test/widget_test.dart` | 1 | UI loading → error → retry → success |
| `test/todo_provider_test.dart` | 2 | Filter, immutable state, ID, judul |
| `test/todo_tile_test.dart` | 1 | Status checkbox, teks tercoret, callback |
| `test/todo_app_test.dart` | 4 | Tambah tugas, filter, navigasi/back/state, direct route |
| `week3_navigation/test/widget_test.dart` | 1 | Home–Detail, back, dan akses path detail |

Total **14 test aplikasi utama + 1 test proyek navigasi**, dijalankan dengan
perintah terpisah dari masing-masing folder proyek. Rincian verifikasi akhir
ada di [docs/step-7-verifikasi.md](docs/step-7-verifikasi.md).

Commit refactoring sebelumnya:
[`da2f146`](https://github.com/raditya12/244107020204-mobile-course/commit/da2f1461ccb646e6f5d98c078d788e478f6b9c8d)
— `jobsheet 3 pemrograman mobile refactoring dan testing`.

## Step 7 — Tugas dan refleksi

### A. Mini project / Industry Challenge

**Judul:** Aplikasi ToDo dengan GoRouter dan Riverpod.

**Tujuan:** membangun aplikasi daftar tugas yang memisahkan tampilan, state,
dan navigasi, sekaligus menunjukkan penanganan proses asinkron yang dapat diuji.

**Fitur utama:** tambah tugas, penolakan judul kosong, toggle selesai, hapus,
filter belum selesai, navigasi daftar/statistik, simulasi pengambilan statistik,
retry ketika gagal, dan state yang bertahan selama sesi navigasi.

| Ketentuan tugas | Pemenuhan dan bukti |
| --- | --- |
| Minimal dua halaman dengan GoRouter | TodoPage `/` dan StatsPage `/stats`; Gambar 9 dan 12 |
| Riverpod Notifier dan ConsumerWidget | TodoListNotifier, TodoPage, StatsPage; sumber pada `lib/` |
| Simulasi asinkron dan tiga state AsyncValue | StatsNotifier dengan delay dua detik dan peluang gagal 30%; Gambar 7–9 |
| Minimal satu unit/widget test lulus | 14 test aplikasi utama; tambahan 1 test proyek navigasi |
| Dokumentasi AI Challenge dan alasan teknis | Step 5, step 6, dan `docs/ai-challenge/` |
| Struktur repository dan laporan | `lib/`, `test/`, `README.md`, `screenshots/`, dan `docs/` di folder minggu ke-3 |

### B. Struktur folder akhir

```text
03-week-3-navigation-state-management/
├── README.md
├── pubspec.yaml
├── pubspec.lock
├── lib/
│   ├── main.dart
│   ├── pages/
│   │   ├── todo_page.dart
│   │   ├── stats_page.dart
│   │   └── product_page.dart
│   ├── providers/
│   │   ├── todo_provider.dart
│   │   ├── stats_provider.dart
│   │   └── products_provider.dart
│   ├── router/app_router.dart
│   └── widgets/todo_tile.dart
├── test/
├── screenshots/
├── docs/
│   ├── ai-challenge/
│   ├── refactoring-testing.md
│   └── step-7-verifikasi.md
├── week3_navigation/        # Proyek Praktikum 1
└── week3_todo/README.md     # Petunjuk lokasi baru proyek ToDo
```

Folder platform Flutter (`android/`, `ios/`, `web/`, dan desktop) juga tersedia.

### C. Cara menjalankan

Dari root repository portfolio:

```sh
cd 03-week-3-navigation-state-management
flutter pub get
flutter run -d chrome
```

Untuk perangkat lain, jalankan `flutter devices` lalu `flutter run -d <device-id>`.
Verifikasi aplikasi utama dari folder minggu ke-3:

```sh
flutter analyze
flutter test
```

Praktikum navigasi awal dijalankan terpisah:

```sh
cd week3_navigation
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Pada Flutter Web digunakan strategi URL bawaan berbasis hash, sehingga route
statistik dapat dibuka melalui `http://localhost:<port>/#/stats`. Route detail
proyek navigasi menggunakan `http://localhost:<port>/#/detail/3`.

### D. Refleksi

#### 1. Kapan setState masih cukup, dan kapan state harus naik ke Riverpod?

`setState` masih cukup jika state hanya dipakai satu widget, misalnya membuka
atau menutup panel, memilih tab lokal, atau menampilkan/menyembunyikan password.
Riverpod lebih tepat ketika data dibagi antarhalaman, memiliki logika bisnis,
berasal dari proses asinkron, atau harus diuji terpisah dari UI. Pada aplikasi
ini daftar ToDo ditempatkan di Notifier agar sumber data tetap sama ketika
halaman berganti. State bertahan selama ProviderScope hidup; Riverpod sendiri
tidak otomatis menyimpan data setelah aplikasi ditutup atau browser direfresh.

#### 2. Apa perbedaan context.go dan context.push, serta penggunaannya?

`context.go` membangun ulang stack sesuai konfigurasi route tujuan. Cocok untuk
berpindah tujuan utama atau redirect, misalnya kembali ke `/`. `context.push`
menambahkan halaman pada stack saat ini, sehingga cocok untuk halaman yang
perlu ditutup dengan back. Pada aplikasi ToDo, statistik dibuka menggunakan
push agar back kembali ke daftar. Pada Praktikum 1, go ke `/detail/3` tetap
menyertakan Home karena detail didefinisikan sebagai child route Home; jadi go
tidak selalu berarti stack hanya berisi satu halaman.

#### 3. Bagaimana AsyncValue mencegah bug dibanding tiga boolean terpisah?

Tiga boolean seperti `isLoading`, `hasError`, dan `isSuccess` dapat membentuk
kombinasi yang tidak valid, misalnya semuanya aktif. AsyncValue menyediakan
representasi loading, error beserta stack trace, serta data dalam satu model
state. UI dapat menangani setiap cabang melalui `when`, dan AsyncValue.guard
mengubah hasil Future atau exception menjadi state yang sesuai. Pada refresh,
AsyncValue juga dapat membawa data sebelumnya sambil memuat ulang; hal ini
dikelola secara terstruktur tanpa menyinkronkan beberapa flag secara manual.
Developer tetap wajib menyediakan tampilan error dan loading yang benar.

#### 4. Bagian hasil AI mana yang diperbaiki, dan mengapa?

Test counter bawaan diganti dengan test statistik karena ekspektasinya tidak
sesuai aplikasi. Integrasi awal yang langsung menampilkan StatsPage diubah
menjadi MaterialApp.router dengan halaman daftar dan statistik agar memenuhi
mini project. Baris ToDo dipisahkan menjadi TodoTile, filter diekstrak menjadi
Provider turunan, dan aksi menggunakan ID stabil untuk menghindari kesalahan
indeks setelah filtering. Pengujian diperluas ke navigasi dan perubahan state.
Pada penyelesaian laporan, test counter proyek navigasi juga diganti dengan
test Home–Detail. Audit awal tidak menemukan kesalahan pada pola immutable,
dependency injection, atau API Riverpod statistik; ketiganya sudah benar sejak
output awal, sehingga tidak dilaporkan sebagai bug yang pernah diperbaiki.

### E. Hasil akhir dan kesimpulan

Aplikasi memenuhi enam kriteria mini project melalui dua halaman, state
Riverpod, simulasi asinkron, pengujian, dokumentasi AI, serta struktur portfolio.
Pengujian utama meliputi perubahan state dan UI, sedangkan proyek navigasi
memverifikasi path parameter serta back. Seluruh 14 screenshot yang tersedia
telah ditempatkan pada bagian laporan sesuai isi gambarnya.

Pembelajaran utama adalah UI dibangun dari state, route mendefinisikan tujuan
navigasi, dan logika terpisah mempermudah pengujian. Data ToDo masih berada di
memori, statistik merupakan simulasi, dan pengujian browser/perangkat bukan
pengganti semua jenis pengujian platform. Pengembangan berikutnya dapat
menambahkan penyimpanan lokal dan sumber statistik nyata.

Repository portfolio:
[244107020204-mobile-course](https://github.com/raditya12/244107020204-mobile-course/tree/main/03-week-3-navigation-state-management).

## Referensi

- [Codelab Navigation & State Management](https://jti-polinema.github.io/flutter-codelab/03-minggu-3-navigation-state-management/index.html#0)
- [Flutter Navigation](https://docs.flutter.dev/ui/navigation)
- [GoRouter](https://pub.dev/packages/go_router)
- [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod)
- [Riverpod](https://riverpod.dev/)
