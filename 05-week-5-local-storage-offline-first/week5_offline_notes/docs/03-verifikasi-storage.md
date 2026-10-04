# Verifikasi AI dan keputusan project

## Tabel final

| Data | Storage yang dipakai | Alasan |
|---|---|---|
| Tema dan waktu dibuka | SharedPreferences | Nilainya kecil dan sederhana |
| Catatan | SQLite / sqflite | Bisa tambah, baca, edit, hapus, dan urutkan berdasarkan waktu |
| Cache bacaan API | SQLite / sqflite | Data bisa dibaca lagi ketika API tidak tersedia |

## Checklist verifikasi

| Pertanyaan jobsheet | Temuan |
|---|---|
| Apakah AI menyimpan catatan di SharedPreferences? | Tidak. Usulan daftar catatan sebagai satu JSON di preferensi ditolak; catatan masuk tabel SQLite. |
| Apakah skema mendukung sync? | Ya, ada `dirty` dan `updated_at`. Tambah/edit membuat dirty aktif. |
| Apakah klaim real-time didukung stream? | Drift memiliki `watch()` dan Hive memiliki event box. sqflite tidak otomatis reaktif; project menggunakan invalidasi provider. |
| Apakah boilerplate masuk akal? | Untuk paket yang dipakai, bisa diperiksa dari repository preferensi, model, pembuka database, dan repository catatan yang sudah berjalan. Instalasi tercatat pada pubspec/lock. Hive/Drift belum dicoba di project ini; perkiraan setup keduanya belum diverifikasi lewat instalasi. |
| Bagaimana migrasinya? | Database praktikum versi 1 membuat dua tabel. Belum ada perubahan skema sehingga belum ada migrasi versi 2 yang diuji. Indeks rekomendasi AI untuk 1000+ catatan belum diterapkan. |
| Apa keputusan final? | Project mempertahankan SharedPreferences + sqflite: cukup untuk kebutuhan praktikum dan mudah dijelaskan. |

Rekomendasi tersebut diterapkan pada project; penilaian pribadi mahasiswa atas pilihan ini perlu dipahami sebelum demo.

## Aturan konflik

Pilihan aturan: **last-write-wins**, berdasarkan `updated_at` UTC. Versi paling baru dipilih; timestamp sama dianggap versi yang sama. Backend pada praktikum berupa simulasi, sehingga belum ada penggabungan versi remote. Saat upload berjalan, kode hanya membersihkan versi lokal yang timestamp-nya masih sama. Edit yang lebih baru tetap masuk antrean.

Penghapusan masih menghapus data lokal. Jika memakai backend nyata, operasi hapus perlu tombstone/outbox agar dapat ikut disinkronkan.

## Verifikasi yang dilakukan

- Unit test mapping model dan serialisasi dirty.
- Test provider memakai repository palsu, termasuk hasil sukses dan error.
- Test CRUD SQLite in-memory, upload gagal, dan edit selama upload.
- Test cache-first dan halaman detail yang membaca repository lokal.
- Pengujian UI Chrome untuk cache API, offline, CRUD, sync, detail, serta preferensi setelah reload.

Hasil aktual perintah dan screenshot dirangkum di README. Pengujian awal menggunakan Chrome. Pengguna kemudian memasang aplikasi pada HP Android dan memberikan lima screenshot: cache saat online, mode pesawat, catatan dengan badge 1, detail offline, dan kondisi akhir online dengan badge 0 serta daftar kosong. Bukti ini mendukung pembacaan cache/catatan dalam mode pesawat; screenshot akhir mobile belum memastikan sinkronisasi catatan karena daftar kosong. Bukti perubahan status sync tersedia dari pengujian Chrome. Uji beban 1000+ catatan belum dilakukan; skema pada jawaban AI adalah rancangan, bukan bukti benchmark.
