# Laporan Praktikum Mobile - Week 1

- **Nama:** RADITYA RIEFKI
- **NIM:** 244107020204
- **Kelas:** TI-3E

## Tujuan

Proyek ini dibuat sebagai latihan awal Pemrograman Mobile untuk memahami ekosistem dan struktur dasar aplikasi Flutter. Hasil praktikum awal berupa halaman profil mahasiswa sederhana.

Screenshot di bawah mendokumentasikan praktikum awal. Kode `lib/main.dart` saat ini sudah dikembangkan menjadi **Student Dashboard** dengan ringkasan akademik, tata letak responsif, dan pilihan mode gelap.

## Fitur Utama

- **Praktikum awal:** menampilkan profil mahasiswa yang terdiri dari nama, NIM, semester, dan informasi mata kuliah.
- **Pengembangan saat ini:** menampilkan jumlah mata kuliah, tugas, persentase kehadiran, dan IPK dalam dashboard responsif dengan pilihan mode terang/gelap.

## Stack Teknologi

- **Flutter 3.47.1** sebagai framework aplikasi lintas platform.
- **Dart 3.13.1** sebagai bahasa pemrograman.
- **Material Design** untuk widget dan tampilan antarmuka.
- **Flutter Test** untuk pengujian widget.
- **Android SDK dan Gradle** untuk membangun aplikasi Android.

## Struktur Folder Repository

```text
01-week-1-mobile-development-ecosystem-flutter-refresh/
├── README.md
├── lib/
│   └── main.dart
├── test/
│   └── widget_test.dart
└── screenshots/
```

File `.gitignore` mengatur agar repository hanya menyimpan laporan, kode praktikum, pengujian, dan screenshot. File pendukung Flutter seperti `pubspec.yaml`, folder platform (`android/`, `ios/`, dan lainnya), serta hasil build disimpan secara lokal.

## Cara Menjalankan

### Persiapan setelah clone

Jika `pubspec.yaml` belum tersedia, buka terminal pada direktori Week 1 lalu buat file pendukung Flutter:

```bash
flutter create --project-name my_first_app .
```

Gunakan nama proyek `my_first_app` agar sesuai dengan import pada `test/widget_test.dart`. Jalankan perintah tanpa opsi `--overwrite` agar kode praktikum yang sudah ada dipertahankan. File pendukung yang dihasilkan akan diabaikan Git sesuai `.gitignore`.

### Menjalankan pada HP

1. Buka terminal pada direktori proyek ini.
2. Sambungkan HP ke laptop melalui kabel USB, aktifkan **USB Debugging**, lalu izinkan koneksi debugging pada HP.
3. Unduh dependensi dan pastikan perangkat terdeteksi:

   ```bash
   flutter pub get
   flutter devices
   ```

4. Jalankan aplikasi:

   ```bash
   flutter run
   ```

## Langkah-Langkah Praktikum

### 1. Menyiapkan Environment & Verifikasi

- Menginstal Git, Flutter SDK, VS Code beserta ekstensi Flutter & Dart, serta Android Studio dengan Android SDK dan Command-line Tools.
- Menjalankan verifikasi instalasi melalui terminal dengan perintah:

  ```bash
  flutter --version
  flutter doctor
  ```

- Memastikan tidak ada kendala pada konfigurasi Flutter dan Android SDK.

**Screenshot: `INSTALLASI FLUTTER.jpg`**

![Instalasi Flutter](screenshots/INSTALLASI%20FLUTTER.jpg)

**Screenshot: `INSTALLASI FLUTTER 2.jpg`**

![Instalasi Flutter 2](screenshots/INSTALLASI%20FLUTTER%202.jpg)

**Screenshot: `INSTALLASI DAN VERIFIKASI.jpg`**

![Instalasi dan Verifikasi](screenshots/INSTALLASI%20DAN%20VERIFIKASI.jpg)

### 2. Membuat dan Menjalankan Proyek Flutter Pertama

- Membuka terminal pada direktori kerja dan membuat proyek Flutter baru:

  ```bash
  flutter create my_first_app
  ```

- Membuka direktori proyek yang baru dibuat di VS Code.
- Memilih target perangkat fisik (USB Debugging) atau emulator yang terdeteksi melalui `flutter devices`.
- Menjalankan aplikasi menggunakan `flutter run`.

**Screenshot: `MENJALANKAN DAN MENJALANKAN FLUTTER.jpg`**

![Menjalankan Flutter](screenshots/MENJALANKAN%20DAN%20MENJALANKAN%20FLUTTER.jpg)

### 3. Mengubah UI Default

- Membuka file `lib/main.dart` dan memperbarui tampilan default dengan struktur profil sederhana menggunakan widget `Scaffold`, `AppBar`, `Center`, `Column`, `Icon(Icons.school)`, dan `Text`.
- Mengamati efisiensi perubahan tampilan menggunakan *Hot Reload* (`r`) dan *Hot Restart* (`R`).

**Screenshot: `MENGUBAH UI DEFAULT.jpg`**

![Mengubah UI Default](screenshots/MENGUBAH%20UI%20DEFAULT.jpg)

### 4. Mini Assignment: Profil Mahasiswa

- Mengembangkan antarmuka Profil Mahasiswa dengan menambahkan informasi identitas diri (Nama, NIM, Kelas) dan informasi mata kuliah menggunakan widget dasar Flutter.
- Melakukan verifikasi tampilan aplikasi pada perangkat.

**Screenshot: `Mini Assignment.jpg`**

![Mini Assignment](screenshots/Mini%20Assignment.jpg)

## Hasil yang Dicapai

- Aplikasi profil mahasiswa berhasil dibuat menggunakan struktur dasar Flutter.
- Antarmuka berhasil menampilkan AppBar, ikon sekolah, nama mahasiswa, NIM, semester, dan informasi mata kuliah.
- Pengujian widget pada kode saat ini mencakup tampilan dashboard, pergantian mode gelap, dan label aksesibilitas.
- Proyek dapat dijalankan pada Android maupun browser yang didukung Flutter.

## Pengujian

Jalankan pemeriksaan kode dan pengujian widget dari direktori proyek:

```bash
flutter analyze lib test
flutter test
```

## Kendala yang Ditemui

HP menolak instalasi aplikasi melalui USB. Untuk mengatasinya, periksa opsi **USB Debugging** dan **Install via USB** (jika tersedia) pada pengaturan pengembang, lalu setujui permintaan izin yang muncul pada HP.

## Refleksi

- **Kapan native lebih tepat dipilih daripada cross-platform?**

  Native lebih cocok jika membutuhkan performa tinggi dan akses fitur platform yang lebih mendalam. Cross-platform lebih cocok untuk pengembangan cepat di beberapa platform, seperti Android dan iOS.

- **Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?**

  Saat state berubah melalui mekanisme seperti `setState`, Flutter membangun ulang bagian widget tree terkait sehingga UI menampilkan kondisi terbaru.

- **Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portofolio?**

  Tim lebih mudah melacak perubahan, meninjau kode, dan mencari penyebab bug. Riwayat commit juga membantu menunjukkan proses pengembangan dalam portofolio.
