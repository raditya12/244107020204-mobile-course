# Review checklist mid project

Tanggal: 27 Oktober 2026.
Project: `07-week-7-clean-architecture/week7_clean_notes`.
Target: kesiapan paruh semester, bukan menambah fitur baru.

## 1. Audit riwayat sebelum perbaikan

```text
git log --oneline -15
c1aed75 jobsheet 7 pemrograman mobile
7c0ea14 jobsheet 6 pemrograman mobile
2dcee17 Delete Week7.ipynb
383610c Modul 7
86910d9 Modul 7
5f49e84 jobsheet 5 pemrograman mobile
1fdc473 jobsheet 4 pemrograman mobile
9681ac5 Delete Quiz1.ipynb
3225871 Quizz
c40705c jobsheet 3 pemrograman mobile
ca20112 jobsheet 3 tugas refleksi dan laporan step 1-7
da2f146 jobsheet 3 pemrograman mobile refactoring dan testing
d1e0661 jobsheet 2 pemrograman mobile
35588ce Step 4 Praktikum: layout sederhana (warm-up)
ddd7c9f jobsheet 1 pemrograman mobile

git branch -a
  backup/history-before-week1-cleanup-1083fd2
* main
  remotes/origin/main

git status
 M .vscode/settings.json
 M 05-week-5-local-storage-offline-first/week5_offline_notes/README.md
```

Masalah yang ditemukan:

1. Semua commit masuk langsung ke `main`; belum ada `develop`.
2. Pesan commit tidak konsisten (`jobsheet 7 pemrograman mobile`,
   `Modul 7`, `Delete Week7.ipynb`) sehingga sulit dicari dan di-revert.
3. Belum ada issue atau Pull Request sebagai kontrak review.
4. `dart format --set-exit-if-changed lib test` gagal pada 13 file.
5. Dua file termodifikasi di working tree tidak berhubungan dengan Week 8
   (`.vscode/settings.json` dan README Week 5); keduanya **tidak** ikut
   di-commit.

## 2. Perbaikan pesan commit (tabel sebelum/sesudah)

| Sebelum | Sesudah (usulan format conventional) | Alasan |
|---|---|---|
| `jobsheet 7 pemrograman mobile` | `docs(week7): tambah laporan jobsheet clean architecture` | Menyebut tipe perubahan (dokumentasi), cakupan (week7), dan isi (laporan clean architecture). |
| `jobsheet 6 pemrograman mobile` | `docs(week6): tambah laporan jobsheet authentication & FCM` | Menghindari pesan generik; pembaca langsung tahu fitur yang dilaporkan. |
| `Modul 7` | `docs(week7): tambah modul praktikum clean architecture` | Menjelaskan bahwa yang ditambah adalah modul/slide, bukan kode aplikasi. |
| `Delete Week7.ipynb` | `chore(repo): hapus notebook Week7 yang tidak dipakai` | Menyebut alasan penghapusan agar riwayat tidak terlihat seperti kecelakaan. |

Aturan ke depan:

```text
tipe(scope): deskripsi singkat
tipe  : feat | fix | refactor | test | docs | chore | style
scope : notes | posts | settings | ci | repo | week8
```

## 3. Branch dan alur kerja

```text
main       -> tetap di c1aed75, tidak disentuh
develop    -> integrasi; dibuat dari main
chore/quality-gate
           -> style: rapikan format lib dan test
           -> chore(ci): tambah workflow analyze, format, dan test
fix/notes-delete-layer
           -> refactor(notes): pindahkan hapus catatan dari widget ke provider + test
           -> docs(week8): laporan mid project review + verifikasi AI
```

Branch fitur di-merge ke `develop` dengan `--no-ff`. Push ke GitHub dan
pembuatan PR ditunda; draft issue/PR tersedia di
[`issue-pr-draft.md`](issue-pr-draft.md).

## 4. Checklist kesiapan paruh semester

| Butir | Status | Bukti |
|---|---|---|
| Struktur feature-first terbukti | Lulus | `domain`/`core` bebas import Flutter/Dio/SQLite (0 match); presentation bebas akses data mentah (0 match); widget/pages bebas repository (0 match). |
| `flutter analyze` bersih | Lulus | `No issues found!` |
| `dart format` rapi | Lulus setelah perbaikan | Baseline 13 file berubah; setelah `dart format lib test`, gate exit 0. |
| `flutter test` hijau | Lulus | 25 test, `All tests passed!` (naik dari 23). |
| PR kecil dan commit jelas | Lulus | PR kode 76 insertions / 13 deletions; commit conventional. |
| README + screenshot + cara menjalankan | Lulus | `README.md` Week 8 + folder `screenshots/` + langkah `flutter pub get`/`run`/`test`. |
| Komentar review ditindaklanjuti | Lulus | 2 blocker resolved; 3 saran: 2 ditolak dan 1 ditunda, semuanya dengan alasan di [`peer-review.md`](peer-review.md). |
| Review AI diverifikasi | Lulus | 5 temuan + 1 tambahan; 2 diterapkan, 1 false positive ditolak, 1 over-engineering ditolak, 2 ditunda. Lihat [`ai-review-vs-keputusan.md`](ai-review-vs-keputusan.md). |
| CI menolak PR kotor | Lulus (siap) | `.github/workflows/ci.yml` menjalankan format, analyze, dan test. |
| `main` tidak disentuh | Lulus | `main` tetap di `c1aed75`; semua commit baru ada di `develop`. |
| Issue + PR GitHub | Tertunda | Push/PR ditunda sesuai instruksi; draft siap di `docs/issue-pr-draft.md`. |

## 5. Bukti mesin

Dijalankan di `07-week-7-clean-architecture/week7_clean_notes`:

```text
flutter analyze
No issues found!

dart format --output=none --set-exit-if-changed lib test
exit code 0

flutter test
+25: All tests passed!
```

## 6. Verifikasi sterility (tiga grep Minggu 7)

```powershell
# 1. Presentation steril dari akses data mentah
Get-ChildItem -Path lib\features\*\presentation -Recurse -Filter *.dart |
  Select-String -Pattern 'Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode'
# => 0 matches

# 2. Domain + core steril dari framework/package
Get-ChildItem -Path lib\features\*\domain, lib\core -Recurse -Filter *.dart |
  Select-String -Pattern "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase"
# => 0 matches

# 3. Widget/pages tidak memanggil repository langsung
Get-ChildItem -Path lib\features\*\presentation\pages,
  lib\features\*\presentation\widgets -Recurse -Filter *.dart |
  Select-String -Pattern 'noteRepositoryProvider|RepositoryImpl\('
# => 0 matches
```

## 7. Kesimpulan

Kesiapan paruh semester: **LULUS pada level lokal**. Aplikasi berjalan identik
dengan akhir Minggu 7, tiga pemeriksaan mesin hijau, satu PR kecil sudah
di-review dan di-merge ke `develop`, serta temuan AI terdokumentasi dengan
bukti. Satu-satunya butir tertunda adalah publikasi issue/PR ke GitHub.