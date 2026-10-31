# Output awal AI — pilihan storage

## Perbandingan

| Kriteria | SharedPreferences | Hive | sqflite / SQLite | Drift |
|---|---|---|---|---|
| Query | Baca/tulis berdasarkan key | Baca key; filter koleksi biasanya manual | SQL: filter, sort, join, transaksi | SQL dan query Dart yang diperiksa saat generate |
| Relasi | Tidak tersedia | Referensi antarobjek diatur aplikasi | Foreign key dan join | Relasi SQLite dengan API bertipe |
| Reaktivitas | Tidak ada stream query bawaan | `box.watch()` memberi event perubahan; daftar terfilter tetap perlu diolah | Tidak ada stream query bawaan | `watch()` untuk hasil query reaktif |
| Type-safety | Getter primitif; key masih string | Adapter model bertipe; key/box perlu disiplin | Model dan mapping baris ditulis manual | Tabel dan hasil query memakai generated code |
| Boilerplate | Sedikit | Sedikit–sedang; model bisa membutuhkan adapter | Sedang: skema SQL, mapping, repository | Lebih banyak di awal: tabel, generator, migrasi |
| Testing | Mock nilai preferensi | Box sementara dan adapter test | Repository palsu atau SQLite in-memory | Database in-memory dan pengujian stream |

## Rekomendasi

| Kebutuhan | Pilihan | Alasan |
|---|---|---|
| Tema dan waktu dibuka | SharedPreferences | Hanya beberapa nilai sederhana; pemasangannya mudah |
| Catatan dan cache bacaan | sqflite | Cocok untuk data terstruktur, urutan waktu, filter dirty, dan transaksi; sesuai ruang lingkup praktikum |

Drift menjadi pilihan menarik jika aplikasi berkembang dan membutuhkan banyak query reaktif. Hive cocok untuk cache objek sederhana, tetapi pencarian dan relasi yang makin kompleks membutuhkan pekerjaan tambahan. SharedPreferences tidak disarankan untuk menyimpan daftar catatan sebagai satu JSON besar.

## Skema untuk 1000+ catatan

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
CREATE INDEX idx_notes_dirty_updated_at ON notes(dirty, updated_at);

CREATE TABLE cached_posts (
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
```

Skema SQLite mendukung 1000+ baris. Indeks membantu pengurutan dan pencarian antrean. Untuk tampilan besar, tambahkan pagination; jangan membangun semua widget sekaligus. Dua indeks di atas adalah rekomendasi pengembangan, belum migrasi yang diterapkan pada database praktikum ini.

Alternatif Hive adalah box `notes` dengan key ID dan objek berisi `title`, `body`, `updatedAt`, dan `dirty`. Mengambil antrean dirty atau mengurutkan waktu membutuhkan filter/sort tambahan di aplikasi. Drift dapat memakai skema SQLite yang sama dengan definisi tabel dan migrasi bertipe.

## Trade-off

- SharedPreferences paling sederhana, tetapi bukan database koleksi dan tidak menyediakan transaksi lintas record.
- Hive mudah untuk akses objek berdasarkan key, tetapi tidak menyediakan SQL join.
- sqflite memberi kontrol SQL yang jelas, tetapi kesalahan mapping baru terlihat saat runtime dan UI perlu diberi tahu setelah perubahan.
- Drift mengurangi mapping manual dan mendukung stream, tetapi setup generator lebih banyak.
- Dirty flag cocok untuk simulasi upload praktikum. Backend nyata juga membutuhkan identitas remote, kebijakan konflik, serta tombstone/outbox untuk penghapusan.
