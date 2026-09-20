# Laporan Praktikum Pemrograman Mobile Week 3

## Navigation & State Management

Nama : Raditya Riefki
NIM : 244107020204

## Praktikum 1 — Aplikasi multi-page dengan GoRouter

## Struktur dan menjalankan proyek

```text
03-week-3-navigation-state-management/
├── README.md
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── pages/
│   ├── providers/
│   ├── router/
│   └── widgets/
├── test/
├── screenshots/
├── docs/
└── week3_navigation/  # Praktikum navigasi sebelumnya
```

Proyek utama ToDo sekarang berada langsung dalam folder minggu ke-3.
Nama package tetap `week3_todo`. Folder `week3_todo/` lama hanya menyimpan
petunjuk pemindahan; perintah pada laporan AI challenge di bawah merupakan
catatan historis sebelum refactoring.

Dari folder `03-week-3-navigation-state-management`, jalankan:

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

## 5. AI challange

### 5.1 Tujuan dan prompt

Langkah pertama adalah memberikan prompt kepada AI untuk membuat halaman StatsPage pada proyek week3_todo menggunakan flutter_riverpod. Halaman ini menggunakan ConsumerWidget dan satu AsyncNotifierProvider untuk mengambil data statistik dengan simulasi waktu tunggu dua detik serta kemungkinan gagal sebesar 30%. Halaman harus menampilkan kondisi loading, error, dan success, serta dilengkapi unit test dan komentar penjelas.

Prompt awal dan instruksi verifikasi disimpan dalam [dokumen prompt](docs/ai-challenge/01-prompts.md). Langkah kedua adalah memeriksa hasil AI yang terdiri dari model statistik, notifier, provider, halaman statistik, integrasi halaman awal, unit test, dan widget test. Hasil implementasi awal diarsipkan dalam [dokumen output awal AI](docs/ai-challenge/02-output-awal.md).

### 5.2 Verifikasi immutable state

Langkah ketiga adalah memeriksa apakah perubahan state dilakukan secara immutable. Hasil pemeriksaan menunjukkan bahwa model StatItem memiliki properti yang tidak dapat ditugaskan ulang dan data statistik dikembalikan sebagai list konstan. Tidak ditemukan penambahan, penghapusan, atau perubahan elemen secara langsung pada list state statistik. Saat pengguna melakukan retry, Riverpod menjalankan kembali pengambilan data dan mengelola perubahan state async.

Sebagai pembanding, provider todo melakukan perubahan pada salinan list sebelum mengganti state, sedangkan provider produk mengganti state async tanpa memutasi list secara langsung. Berdasarkan pemeriksaan tersebut, implementasi statistik memenuhi ketentuan immutable state.

### 5.3 Verifikasi penggunaan ref.watch dan callback

Langkah keempat adalah memeriksa penggunaan ref.watch, ref.read, dan ref.invalidate. Pada StatsPage, ref.watch digunakan di dalam build agar tampilan diperbarui ketika state provider berubah. Tidak ditemukan penggunaan ref.watch di dalam callback tombol.

Tombol Coba lagi menggunakan ref.invalidate untuk memuat ulang data statistik. Penggunaan ini sudah tepat karena callback hanya perlu memulai pengambilan data kembali. Ref.read tidak diperlukan pada callback tersebut karena tidak ada nilai yang perlu dibaca atau metode notifier yang perlu dipanggil. Pada halaman todo, ref.read digunakan dalam callback untuk memanggil metode notifier. Dengan demikian, penggunaan akses provider sudah sesuai dengan kebutuhan masing-masing halaman.

### 5.4 Verifikasi tiga state AsyncValue

Langkah kelima adalah memeriksa penanganan loading, error, dan success. Ketiga keadaan tersebut sudah ditangani. Saat data sedang dimuat, halaman menampilkan spinner di tengah layar. Jika pengambilan data gagal, halaman menampilkan pesan kesalahan dan tombol Coba lagi. Jika pengambilan data berhasil, halaman menampilkan ListView dengan tepat tiga item statistik.

Spinner juga ditampilkan ketika pengguna mencoba kembali setelah terjadi kesalahan. Retry otomatis dinonaktifkan agar pesan kesalahan tetap terlihat sampai pengguna menekan tombol. Widget test telah membuktikan alur loading, error, retry, dan success sehingga implementasi tidak hanya menangani kondisi berhasil.

### 5.5 Verifikasi tipe dan duplikasi provider

Langkah keenam adalah memeriksa tipe provider dan kemungkinan duplikasi. Provider statistik sudah menggunakan tipe notifier StatsNotifier dan tipe data berupa list StatItem yang ditulis secara eksplisit pada generic provider. Tipe variabel provider kemudian dikenali oleh Dart dari deklarasi tersebut.

Hanya terdapat satu deklarasi provider statistik dalam sumber aplikasi. Provider produk dan provider todo memiliki data serta tanggung jawab yang berbeda sehingga bukan duplikat provider statistik. Penggantian implementasi provider dalam test hanya berlaku pada lingkungan pengujian dan tidak menambahkan provider statistik kedua ke aplikasi. Pemeriksaan tipe dan duplikasi provider dinyatakan lulus.

### 5.6 Verifikasi API Riverpod

Langkah ketujuh adalah memeriksa kesesuaian API dengan dependensi flutter_riverpod versi 3.4.3 atau versi yang kompatibel sesuai konfigurasi proyek. Implementasi statistik sudah menggunakan AsyncNotifier dan AsyncNotifierProvider, sedangkan halaman menggunakan ConsumerWidget.

Tidak ditemukan penggunaan StateProvider, StateNotifierProvider, atau Consumer bertingkat yang tidak diperlukan dalam sumber aplikasi week3_todo. Provider todo juga sudah menggunakan NotifierProvider dan provider produk menggunakan AsyncNotifierProvider. Oleh karena itu, tidak diperlukan perbaikan tambahan untuk migrasi ke pola Notifier dan ConsumerWidget.

### 5.7 Verifikasi analyzer dan test

Langkah kedelapan adalah menjalankan flutter analyze dan flutter test dari direktori week3_todo. Pengujian ulang pada 18 September 2026 menunjukkan bahwa analyzer selesai tanpa temuan, warning, error, maupun info. Seluruh tujuh test juga berhasil dijalankan tanpa warning pada output pengujian. Jumlah tersebut terdiri dari enam unit test notifier dan satu widget test.

Unit test memeriksa kondisi loading, permintaan waktu tunggu dua detik, isi tiga statistik, batas angka acak yang menentukan kegagalan, serta retry dari error menuju success. Waktu tunggu dan angka acak dikontrol dalam unit test agar hasilnya konsisten. Widget test menggunakan waktu virtual untuk memeriksa perubahan tampilan selama pengambilan data dan retry.

Pengujian peluang gagal memastikan bahwa angka acak di bawah batas 30% menghasilkan error. Peluang tersebut tidak berarti setiap sepuluh permintaan pasti mengalami tepat tiga kegagalan. Berdasarkan hasil analyzer dan test, implementasi dinyatakan lulus verifikasi otomatis. Rincian pelaksanaan dan hasilnya disimpan dalam [dokumen testing](docs/ai-challenge/04-testing.md).

### 5.8 Perbaikan dan tanggung jawab teknis

Langkah kesembilan adalah mencatat perubahan implementasi dan hasil audit. Pada implementasi awal, AI menambahkan halaman statistik, notifier, serta pengujian, kemudian menjadikan StatsPage sebagai halaman awal aplikasi. Test counter bawaan yang sudah tidak sesuai dengan aplikasi diganti menjadi widget test untuk halaman statistik.

Implementasi awal sudah menggunakan data immutable, dependensi yang dapat dikontrol saat pengujian, retry manual, dan API Riverpod modern. Audit lanjutan tidak menemukan masalah yang memerlukan perubahan kode Dart. Perubahan pada tahap audit berupa penambahan dokumentasi checklist, pengarsipan tanggung jawab teknis, dan penyesuaian judul laporan menjadi Week 3. Riwayat tersebut dicatat dalam [dokumen perbaikan](docs/ai-challenge/03-perbaikan.md).

Langkah kesepuluh adalah mempersiapkan penjelasan kode saat demo. [Panduan demo](docs/ai-challenge/05-panduan-demo.md) memuat penjelasan bagian kode berdasarkan nomor baris, mulai dari import, model data, provider, proses async, tampilan, callback, hingga pengujian. Demo dilakukan dengan menjalankan aplikasi, menunjukkan proses loading dan hasil statistik, serta mencoba kembali ketika muncul error. Widget test dapat digunakan untuk menunjukkan alur error dan retry secara konsisten karena kegagalan dalam aplikasi terjadi secara acak.

Seluruh prompt, output awal AI, catatan perbaikan, hasil testing, dan panduan demo telah disimpan dalam folder docs tugas minggu ini. Seluruh checklist teknis dinyatakan lulus berdasarkan pemeriksaan sumber dan pengujian otomatis. Mahasiswa tetap bertanggung jawab memahami serta mampu menjelaskan setiap baris kode saat demo. Dokumentasi ini merupakan bahan persiapan dan tidak menyatakan bahwa demo telah dilakukan.

## 6. Refactoring dan testing

1. Baris tugas dipisahkan menjadi `TodoTile` di `lib/widgets/todo_tile.dart`.
   Widget menerima data dan callback sehingga dapat diuji tanpa ProviderScope.
2. `filteredTodosProvider` membaca `todoListProvider` dan `todoFilterProvider`.
   Switch **Hanya yang belum selesai** mengaktifkan filter. Toggle dan hapus
   menggunakan ID stabil, bukan indeks hasil filter.
3. `MaterialApp.router` menggunakan GoRouter dengan `/` untuk daftar dan
   `/stats` untuk statistik. `ShellRoute` menyediakan NavigationBar. Navigasi
   ke statistik menggunakan push agar back kembali ke daftar.
4. `ProviderScope` membungkus aplikasi sehingga daftar dan pilihan filter
   bertahan selama berpindah halaman dalam sesi aplikasi.
5. Halaman statistik AI challenge tetap menangani AsyncValue loading, error,
   retry, dan success. Angka statistik merupakan data simulasi dari challenge.

Verifikasi 20 September 2026: `flutter analyze` menghasilkan **No issues found!**
dan `flutter test` menghasilkan **14 test lulus**. Pengujian meliputi tambah
tugas sesuai contoh jobsheet, filter/toggle/hapus, TodoTile, navigasi/back,
akses langsung `/stats`, persistensi state antarhalaman, dan alur AsyncValue.

Rincian hasil dan checklist: [Verifikasi refactoring](docs/refactoring-testing.md).
