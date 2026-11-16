# Performance Report — Jobsheet 11

**Tanggal:** 9 November 2026
**Project:** `week11_ai_notes`
**Basis:** project Minggu 10 (`week10_ai_notes`)

## 1. Metode pengukuran

Dua lapis bukti dipakai agar optimasi tidak placebo:

1. **Metrik rebuild terukur (otomatis).** Instrumentasi
   [`lib/core/rebuild_stats.dart`](../lib/core/rebuild_stats.dart) menghitung
   jumlah build per label widget. Pencatatan berada di dalam `assert`
   (biaya nol di release). Widget test
   [`test/rebuild_perf_test.dart`](../test/rebuild_perf_test.dart) menjalankan
   skenario "toggle mode offline" dan menghitung delta build per widget
   sebelum/sesudah optimasi.
2. **Profiling DevTools (manual).** Langkah `flutter run --profile` →
   DevTools → tab Performance → Record (buka daftar, scroll, toggle offline,
   buka chat, kembali) → Stop → simpan `screenshots/before-profile.png` dan
   `screenshots/after-profile.png`. Langkah ini memerlukan sesi DevTools
   interaktif dan didokumentasikan sebagai prosedur manual; metrik rebuild
   otomatis di atas adalah penyebab jank #1 sesuai codelab dan sepenuhnya
   terverifikasi otomatis.

## 2. Baseline (sebelum optimasi)

Skenario: halaman utama dengan 1 catatan + 12 bacaan cache, viewport tinggi,
lalu toggle mode offline satu kali.

```text
REBUILD_DELTAS_OFFLINE_TOGGLE={NotesPage: 1, NoteTile: 1, PostsSection: 1}
```

Artinya: satu toggle (aksi UI kecil yang hanya mengubah status offline)
me-rebuild halaman utama, tile catatan, dan seluruh section bacaan.
Kombinasi dengan Temuan 2 (provider bacaan reload cache per toggle) berarti
setiap toggle juga membaca ulang SQLite — kerja ulang yang tidak perlu.

Temuan lengkap: [`performance-findings.md`](performance-findings.md).

## 3. Optimasi yang diterapkan

| # | Teknik (dari codelab) | Implementasi | Alasan |
|---|---|---|---|
| 1 | Ekstraksi widget + Riverpod `select` | Kartu offline diekstrak ke [`offline_card.dart`](../lib/features/notes/presentation/widgets/offline_card.dart) (mem-watch `forceOfflineProvider`, `dirtyCountProvider.select(value)`, `syncProvider.select(isLoading)`); header bacaan diekstrak ke `PostsHeader` | Hanya widget kecil yang memang menampilkan status offline yang rebuild; chip dan tombol sinkron tidak ikut rebuild saat nilai lain berubah |
| 2 | Provider steril dari watch berlebih | `PostsNotifier.build()` mem-`read` (bukan watch) `forceOfflineProvider` | Toggle offline tidak lagi me-reload cache SQLite dan tidak menjadwalkan ulang refresh API |
| 3 | Lazy loading | Body halaman diganti `CustomScrollView` + `SliverList` (`SliverChildBuilderDelegate`) | Hanya item terlihat (plus cacheExtent) yang dibangun, menggantikan `ListView(children:)` + `Column(map)` |
| 4 | Pagination (infinite scroll) | `postsPaginationProvider` (10 per halaman) + `ScrollController` listener mendekati ujung daftar + auto-load saat konten masih muat di layar | Pengguna dapat menjelajah 100 bacaan cache, bukan potongan statis 5 |
| 5 | `RepaintBoundary` + const | `NoteTile` dan `PostTile` dibungkus `RepaintBoundary`; `PostTile` const | Paint tiap tile terisolasi saat scroll |
| 6 | Perbaikan kualitas terkait performa | `refreshErrorProvider` reaktif; trailing pagination statis (bukan spinner tak berujung) | Error refresh tampil segera; animasi tak berujung di luar layar hilang |

## 4. Hasil verifikasi (setelah optimasi)

Skenario yang sama (toggle offline satu kali):

```text
REBUILD_DELTAS_OFFLINE_TOGGLE_AFTER={NotesPage: 0, NoteTile: 0, PostTile: 0}
```

| Metrik | Baseline | Sesudah | Selisih |
|---|---|---|---|
| Rebuild `NotesPage` per toggle | 1 | **0** | -1 |
| Rebuild tiap `NoteTile` per toggle | 1 | **0** | -1 |
| Rebuild daftar bacaan per toggle | 1 (header + seluruh tile) | **0** (tile; hanya `PostsHeader` kecil yang rebuild) | -n |
| Reload cache SQLite per toggle | 1x | **0x** | dihapus |
| Bacaan yang bisa dijelajah | 5 (statis) | **seluruh cache** (10/halaman, infinite scroll) | fitur baru |

Widget yang masih rebuild per toggle dan memang seharusnya: `OfflineCard`
(menampilkan status offline) dan `PostsHeader` (subtitel + tombol refresh).

Pembuktian tambahan (test):

- `rebuild_perf_test.dart` → "toggle offline tidak me-rebuild halaman dan
  tile": assert `delta == 0` untuk halaman dan kedua jenis tile.
- `rebuild_perf_test.dart` → "bacaan dimuat bertahap saat scroll": 25 bacaan
  termuat bertahap, diakhiri "Semua 25 bacaan ditampilkan".
- Suite penuh 44 test hijau, stabil 3x beruntun.

## 5. Bukti mesin

```text
flutter analyze
No issues found! (ran in 4.3s)

dart format --output=none --set-exit-if-changed lib test
Formatted 59 files (0 changed) in 0.20 seconds.
format_exit=0

flutter test (3x beruntun)
00:04 +44: All tests passed!
00:04 +44: All tests passed!
00:04 +44: All tests passed!
```

## 6. Trade-off

| Trade-off | Keputusan | Alasan |
|---|---|---|
| Toggle ke online tidak lagi auto-refresh API di background | Diterima | Auto-refresh per toggle adalah penyebab reload; tombol "Refresh bacaan" tetap tersedia dan perilaku cache-first saat pertama buka tidak berubah |
| Trailing pagination statis, bukan spinner | Diterima | Animasi tak berujung di luar layar boros CPU/baterai dan tidak pernah berhenti di test; penanda teks informatif cukup |
| `RebuildStats` tetap di kode | Diterima | Assert-only (nol biaya release); berguna untuk mengukur regresi rebuild di masa depan |
| Refactor `CustomScrollView` menyentuh halaman utama | Diterima dengan mitigasi | Risiko dilindungi 44 test, termasuk seluruh test UI lama yang tetap hijau tanpa perubahan asersi |
| Optimasi premature (migrasi Hive, sliver di halaman kecil) | Dihindari | Tidak ada bukti bottleneck; lihat tabel "tidak diubah" di findings |

## 7. Prosedur profiling manual (DevTools)

```bash
cd 11-week-11-performance-optimization
flutter run --profile -d chrome
# DevTools terbuka otomatis (atau buka URL yang dicetak terminal)
# Tab Performance -> Record -> lakukan: buka daftar, scroll cepat,
# toggle offline, buka chat, kembali -> Stop
# Simpan Flame Chart sebagai screenshots/before-profile.png
# Ulangi setelah optimasi -> screenshots/after-profile.png
# Tab Memory -> Heap Snapshot sebelum/sesudah navigasi bolak-balik 5x
```

Catatan: gunakan mode `--profile`, bukan `--debug`, agar angka akurat
(overhead debug signifikan) sesuai codelab.
