# Performance Findings — Jobsheet 11

**Tanggal:** 9 November 2026
**Project:** `week11_ai_notes` (basis: project Minggu 10)
**Metode:** instrumentasi hitung rebuild (`lib/core/rebuild_stats.dart`,
assert-only) + analisis kode + widget test terukur. Profiling Flame Chart
DevTools didokumentasikan sebagai langkah manual (lihat
[`performance-report.md`](performance-report.md)).

## Temuan 1 — Toggle offline me-rebuild seluruh halaman (blocker)

`NotesPage` mem-watch `forceOfflineProvider` langsung di root build.
Setiap toggle memicu rebuild halaman, termasuk seluruh tile catatan dan
section bacaan yang tidak menampilkan status offline.

Bukti terukur (baseline, sebelum optimasi):

```text
REBUILD_DELTAS_OFFLINE_TOGGLE={NotesPage: 1, NoteTile: 1, PostsSection: 1}
```

Satu toggle → halaman + tile catatan + section bacaan semuanya rebuild.
Lokasi: `notes_page.dart` (lama), `ref.watch(forceOfflineProvider)` pada
baris pertama build.

## Temuan 2 — Provider bacaan me-reload cache saat toggle offline (blocker)

`PostsNotifier.build()` mem-watch `forceOfflineProvider`, sehingga toggle
offline menyebabkan `build()` dijalankan ulang: bacaan dibaca ulang dari
SQLite dan (saat online) refresh API dijadwalkan ulang — padahal isi cache
tidak berubah.

Bukti: kode `posts_providers.dart` lama (`ref.watch(forceOfflineProvider)`
di build) dan semantics Riverpod 3 (perubahan dependency memicu ulang
`AsyncNotifier.build()`). Setelah optimasi: grep
`watch(forceOfflineProvider)` di `posts_providers.dart` = 0 match, dan
widget test toggle tidak menunjukkan reload.

## Temuan 3 — Daftar tidak lazy dan tanpa pagination (blocker)

- Daftar catatan: `Column(children: items.map(...))` di dalam
  `ListView(children:)` — setiap tile dibangun tiap halaman rebuild.
- Daftar bacaan: `Column` + `.take(5)` statis — lazy loading dan pagination
  dari codelab tidak ada sama sekali; pengguna tidak bisa melihat 100
  bacaan cache.

Bukti: kode lama `posts_section.dart` dan `notes_page.dart`
(`ListView(children:)`, `.map(`), dan grep baseline
`ListView\(children` di `notes_page.dart`.

## Temuan 4 — Error refresh tidak reaktif (saran → diterima)

`refreshError` adalah field biasa pada notifier. Teks error hanya muncul
bila widget kebetulan rebuild karena alasan lain (laten bug). Diperbaiki
menjadi `refreshErrorProvider` (state reaktif) sehingga pesan "Jaringan
gagal..." tampil segera setelah refresh gagal.

## Temuan 5 — Animasi tak berujung di trailing pagination (ditemukan saat verifikasi)

Rancangan awal trailing pagination memakai `CircularProgressIndicator`
(spin tak berujung). SliverList mem-build item hingga cacheExtent di luar
viewport, sehingga animasi berjalan walau tidak terlihat — boros CPU dan
menyulitkan pengujian (`pumpAndSettle` tak pernah selesai). Diganti trailing
statis "Memuat lebih banyak...". `LinearProgressIndicator` yang tersisa hanya
untuk loading transien yang pasti berakhir.

## Kandidat yang dievaluasi dan tidak diubah

| Kandidat | Keputusan | Alasan |
|---|---|---|
| `CachedNetworkImage` + `memCacheWidth` | Tidak relevan | Aplikasi tidak menampilkan gambar (posts JSONPlaceholder teks); mengganti `Image.network` tidak ada objeknya. |
| `ListView(children:)` di `note_detail_page.dart` dan `settings_page.dart` | Dibiarkan | Daftar pendek dengan jumlah item tetap kecil (≤4); refactor sliver menambah kompleksitas tanpa manfaat terukur. |
| Hive/Drift menggantikan SQLite | Ditolak | Cache-first SQLite sudah ada sejak Minggu 7 dan sesuai kebutuhan; migrasi berisiko tanpa bukti bottleneck memori. |
