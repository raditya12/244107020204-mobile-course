# Laporan Praktikum Minggu 4
## Networking & REST API



## Step 1–5 — Praktikum Dasar

Tampilan Daftar Post



<img src="screenshots/flutter%20run%20praktikum%202.jpg" alt="Daftar post" width="350">

### Pengujian Koneksi Bermasalah

Saat tidak dapat terhubung ke server, aplikasi menampilkan pesan error dan tombol
**Coba lagi**. Berikut screenshot pengujian yang telah disediakan.

<img src="screenshots/base%20url%20salah.jpg" alt="Pengujian error koneksi pertama" width="300">
<img src="screenshots/mode%20pesawat.jpg" alt="Pengujian error koneksi kedua" width="300">

### Pagination

Data dimuat secara bertahap ketika pengguna menggulir daftar ke bawah.

<img src="screenshots/pagination.jpg" alt="Hasil pagination" width="350">

## Step 6 — AI Challenge

AI digunakan untuk membantu membuat fitur komentar. Hasilnya diperiksa dan
diperbaiki, terutama agar aplikasi dapat menangani data yang tidak lengkap dan
menampilkan pesan ketika terjadi error.

### Komentar Berhasil Ditampilkan

Aplikasi menampilkan nama, email, dan isi komentar sesuai post yang dipilih.

![Daftar komentar](screenshots/step-6-comments-success.png)

### Pengujian Error dan Coba Lagi

Gangguan server disimulasikan. Aplikasi menampilkan pesan error dan tombol
**Coba lagi**.

![Error komentar](screenshots/step-6-comments-error-500.png)

Setelah mencoba kembali, komentar berhasil dimuat.

![Komentar setelah mencoba kembali](screenshots/step-6-comments-retry-success.png)

Catatan penggunaan AI dan hasil pemeriksaannya disimpan di
[folder docs](week4_api/docs/).

## Step 7 — Refactoring dan Testing

Kode aplikasi dirapikan agar lebih mudah digunakan kembali. Pada tahap ini juga
ditambahkan halaman detail untuk membaca judul dan isi post secara lengkap.

### Tampilan Daftar

![Daftar post setelah dirapikan](screenshots/step-7-post-tile.png)

### Halaman Detail

Pengguna dapat memilih post untuk membaca isinya. Tombol **Lihat komentar**
digunakan untuk membuka komentar pada post tersebut.

![Detail post](screenshots/step-7-detail-cache.png)

Halaman detail juga berhasil dibuka langsung melalui alamat halamannya.

![Detail yang dibuka langsung](screenshots/step-7-detail-deep-link.png)

## Step 8 — Mini Project dan Refleksi

Aplikasi dikembangkan dengan fitur daftar post, detail, komentar, dan pagination.
Pengujian dilakukan pada kondisi memuat data, berhasil, gagal, dan data kosong.

### Saat Memuat Data

![Loading](screenshots/step-8-loading.png)

### Saat Gagal Memuat Data Berikutnya

Gangguan server disimulasikan. Data sebelumnya tetap terlihat dan tersedia
tombol **Coba lagi**.

![Error pagination](screenshots/step-8-pagination-error.png)

### Setelah Mencoba Kembali

Data berikutnya berhasil dimuat dan ditambahkan ke daftar.

![Pagination berhasil](screenshots/step-8-pagination-success.png)

### Semua Data Selesai Dimuat

Setelah 100 post dimuat, muncul keterangan **Semua data termuat.**

![Akhir daftar](screenshots/step-8-pagination-end.png)

### Data Kosong

Kondisi data kosong disimulasikan. Aplikasi menampilkan keterangan bahwa belum
ada data dari server.

![Data kosong](screenshots/step-8-empty.png)



