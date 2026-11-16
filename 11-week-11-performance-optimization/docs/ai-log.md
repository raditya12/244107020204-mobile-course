# AI Log — Jobsheet 11

**Tanggal:** 9 November 2026
**Asisten:** OpenCode (AI coding assistant)
**Project basis:** `10-week-10-ai-feature-integration` (Minggu 10)
**Project kerja:** `11-week-11-performance-optimization`
**Fokus:** optimasi performa (rebuild, lazy loading, pagination, RepaintBoundary)

## 1. Prompt 5 slot

```text
Peran: senior Flutter developer yang disiplin Clean Architecture dan
pengukuran performa.
Konteks: project week11_ai_notes (salinan project Minggu 10), feature-first,
presentation -> domain <- data, Riverpod 3, SQLite, Dio, GoRouter.
Tugas: temukan dan perbaiki minimal 3 bottleneck performa (rebuild berlebih,
lazy loading, pagination) dengan bukti before/after yang terukur.
Batas: jangan ubah arsitektur; jangan tambah dependensi baru; setiap
optimasi harus dibuktikan dengan metrik (delta rebuild) atau test,
bukan perasaan; perilaku fitur yang ada tidak boleh berubah.
Output: daftar temuan + kode optimasi + test before/after + dokumentasi.
```

### Konteks yang ditempel

Struktur fitur `notes` dan `posts`, isi `notes_page.dart` (ListView +
Column.map + watch forceOfflineProvider di root), `posts_section.dart`
(Column + take(5) statis), `posts_providers.dart` (AsyncNotifier yang
watch forceOfflineProvider), dan versi package dari `pubspec.yaml`.
Tidak ada token/secret yang ditempel.

## 2. Output awal AI (analisis performa)

Usulan awal AI terhadap halaman utama:

1. Tambah `const` ke widget statis di build method.
2. Ekstrak kartu offline ke widget terpisah.
3. Ganti `Column(map)` daftar catatan dengan `ListView.builder`.
4. Tambah `CachedNetworkImage` untuk gambar.
5. Bungkus daftar bacaan dengan `RepaintBoundary`.
6. Tambah pagination infinite scroll untuk bacaan.

Verifikasi terhadap usulan: nomor 1, 2, 3, 5, 6 relevan; **nomor 4 tidak
relevan** karena aplikasi tidak menampilkan gambar sama sekali (bukti:
tidak ada `Image.network`/`Image.asset` di lib). AI juga tidak menyadari
dua masalah penting yang ditemukan saat verifikasi: provider bacaan yang
me-reload cache saat toggle offline, dan field `refreshError` yang tidak
reaktif.

## 3. Verifikasi

| Langkah | Yang dilakukan | Hasil |
|---|---|---|
| 1. Baca tiap baris usulan | Cocokkan dengan kode nyata | 1 dari 6 usulan tidak relevan (CachedNetworkImage) |
| 2. Cek API | `CustomScrollView`, `SliverChildBuilderDelegate`, `NotifierProvider`, `select` | Valid di Flutter/Riverpod 3 |
| 3. Instrumentasi | `RebuildStats` assert-only ditambahkan sebelum refactor | Baseline terukur: `{NotesPage: 1, NoteTile: 1, PostsSection: 1}` |
| 4. Refactor | Ekstraksi widget, sliver, pagination, RepaintBoundary | Diterapkan bertahap |
| 5. Test | Suite penuh + 2 test performa baru | 44 test hijau stabil 3x |
| 6. Analisis tambahan | Dua temuan di luar usulan awal | Reload cache per toggle; refreshError tak reaktif |

## 4. Bukti masalah yang ditemukan saat verifikasi

### 4a. Test pagination gagal: `pumpAndSettle` tak pernah selesai

Trailing pagination memakai `CircularProgressIndicator` (animasi tak
berujung). SliverList mem-build item hingga cacheExtent di luar viewport,
sehingga animasi berjalan tanpa terlihat. Bukti output test:

```text
The following assertion was thrown running a test:
pumpAndSettle timed out
```

Perbaikan: trailing statis "Memuat lebih banyak...". Pelajaran: animasi tak
berujung di list adalah beban nyata, bukan sekadar masalah test.

### 4b. Daftar bacaan tak pernah termuat di test

`FakePostRepository(cached: 25)` tanpa `remote` membuat refresh background
menimpa cache dengan daftar kosong (`postsLoaded=0` pada debug print).
Diperbaiki dengan `remote: posts` — sekaligus menegaskan bahwa urutan
cache → refresh menimpa cache adalah perilaku repository yang perlu
dipahami saat menguji.

### 4c. Trailing terduplikasi

Perhitungan `postsBlock = 1 + (shownPosts + 1)` membuat dua indeks trailing.
Bukti debug print: `PAG_DEBUG dup=2 positions=[Offset(207.6, 2304.0),
Offset(207.6, 2348.0)]`. Diperbaiki menjadi `shownPosts + 1`.

## 5. AI review challenge

```text
Review optimasi performa Flutter ini sebagai senior dev.
Konteks: feature-first, Riverpod 3, SQLite + Dio, CustomScrollView sliver.
Fokus: kebenaran, arsitektur, test, regresi perilaku. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

| # | Temuan AI | Level | Keputusan | Alasan teknis dan bukti |
|---|---|---|---|---|
| 1 | Tambah `CachedNetworkImage` untuk optimasi gambar | Saran | **Ditolak** | Tidak ada gambar di aplikasi (grep 0 `Image.network`); optimasi tanpa objek adalah premature. |
| 2 | Hapus watch `forceOfflineProvider` di `PostsNotifier.build()` | Blocker | **Diterima dan diperbaiki** | Baseline menunjukkan toggle memicu ulang provider; setelah diperbaiki, toggle tidak lagi reload cache (test + grep 0 match). |
| 3 | Gunakan `select` untuk chip dirty dan tombol sync | Saran | **Diterima dan diperbaiki** | `dirtyCountProvider.select(value)` dan `syncProvider.select(isLoading)` di `offline_card.dart`; rebuild lokal tanpa menyentuh kartu penuh. |
| 4 | Trailing pagination pakai `CircularProgressIndicator` (mengikuti codelab) | Saran | **Ditolak (diganti statis)** | Animasi tak berujung ter-build di cacheExtent; bukti `pumpAndSettle timed out`; boros CPU di luar layar. |
| 5 | Auto-load halaman berikut saat konten muat di layar | Blocker | **Diterima dan diperbaiki** | Tanpa itu, daftar pendek tidak pernah memuat halaman berikut (tidak ada scroll event). Implementasi: post-frame callback + guard `maxScrollExtent <= 0`. |
| 6 | Baseline tidak bisa diambil setelah refactor | Blocker (proses) | **Diterima (diperbaiki prosesnya)** | Instrumentasi dan test baseline dibuat **sebelum** refactor; baseline `{NotesPage: 1, NoteTile: 1, PostsSection: 1}` dicatat dari run nyata sebelum kode diubah. |

## 6. Bukti grep

### Widget halaman utama tidak lagi memakai ListView(children:)

```powershell
Get-ChildItem -Path lib\features\notes\presentation\pages\notes_page.dart |
  Select-String -Pattern 'ListView\(children|Column\('
# notes_page: hanya CustomScrollView + SliverList; Column.map hilang
```

### Tidak ada watch(forceOfflineProvider) di provider posts

```powershell
Get-ChildItem -Path lib\features\posts\presentation\providers\posts_providers.dart |
  Select-String -Pattern 'watch\(forceOfflineProvider\)'
# => 0 matches
```

### RepaintBoundary dan select benar-benar dipakai

```text
notes_page.dart (RepaintBoundary di tile), posts_section.dart (PostTile),
offline_card.dart (dua pemakaian select)
```

### RebuildStats assert-only (nol biaya release)

```powershell
Select-String -LiteralPath 'lib\core\rebuild_stats.dart' -Pattern 'assert'
# pencatatan dibungkus assert(() { ... }())
```

## 7. Bukti mesin

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

## 8. Checklist verifikasi mandiri

- [x] Prompt 5 slot + konteks tersimpan di dokumen ini.
- [x] `flutter analyze` bersih dan `flutter test` hijau (44 test, 3x).
- [x] Baseline dan hasil after terukur (delta rebuild before/after).
- [x] Satu usulan AI ditolak dengan alasan (CachedNetworkImage).
- [x] Keputusan tiap file dicatat di performance-report.
- [x] Tidak ada secret di kode.