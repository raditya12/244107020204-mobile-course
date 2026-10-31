# Verifikasi AI dan keputusan final

## Checklist verifikasi jobsheet

| Pertanyaan | Temuan |
|---|---|
| Interface repository tinggal di `domain`, implementasi di `data`? | Ya. `domain/repositories/*.dart` berisi `abstract class`, `data/repositories/*_impl.dart` berisi implementasi. AI sempat mengusulkan keduanya tetap di satu folder; ditolak. |
| `domain` bebas import Flutter/Dio/SQLite/Firebase? | Ya, dibuktikan grep (0 hasil), bukan dibaca sekilas. |
| AI membuat use case untuk tiap CRUD satu baris? | Ya pada usulan awal (`GetNote`, `DeleteNote`, `CountDirtyNotes`, `GetDarkMode`, `SetDarkMode`). Saya tolak sebagian; lihat tabel di bawah. |
| Entity bebas mapping? | Ya. `Note` dan `Post` murni tanpa `toMap/fromMap`. Mapping hanya di `NoteModel`/`PostModel`. |
| Wiring DI terpusat di provider, widget tidak `new Repository()`? | Ya. `RepositoryImpl(` hanya muncul di 3 file `presentation/providers/`. Tidak ada di widget/page. |
| Keputusan final dan alasan boleh berbeda dari AI? | Ya, beberapa usulan AI disederhanakan/ditolak dengan alasan tertulis. |

## Tabel usulan AI vs keputusan final

| Usulan AI | Keputusan final | Alasan teknis |
|---|---|---|
| Base class `UseCase<Type, Params>` + `NoParams` | **Ditolak** | Untuk 4 use case, base class generik hanya menambah lapisan tanpa manfaat; Dart `call()` sudah cukup sebagai konvensi. |
| `datasources/` terpisah (local + remote) | **Ditolak** | Hanya ada satu sumber per repository; memecahnya menambah file tanpa menambah abstraksi nyata. Bisa ditambahkan saat sumber bertambah. |
| Use case untuk `GetNote`, `DeleteNote`, `CountDirtyNotes` | **Ditolak** | Pass-through satu baris. Provider memanggil `NoteRepository` langsung (presentation → domain tetap sah). |
| Use case `GetNotes` | **Diterima** | Diwajibkan jobsheet dan menjadi titik uji domain. |
| Use case `AddNote`, `UpdateNote` | **Diterima** | Berisi aturan bisnis validasi (judul tidak kosong) yang tidak boleh bocor ke widget. |
| Use case `SyncNotes` | **Diterima** | Menggabungkan beberapa operasi repository + aturan urutan `updatedAt` + cek offline. |
| Entity `AppPreferences` untuk settings | **Ditolak** | Hanya dua nilai primitif (`darkMode`, `lastOpened`); entity akan jadi wrapper kosong. Cukup repository + record. |
| `core/network/dio_client.dart` | **Ditolak** | Hanya satu pemanggilan Dio; client khusus adalah abstraksi prematur. |
| `error/exceptions.dart` terpisah | **Ditolak** | Cukup satu `core/failures.dart`; exception mentah ditangkap di `data`. |
| `core/database/db.dart` untuk opener | **Diterima, tapi dipindah** ke `infrastructure/database/` | `core` harus bebas framework (grep #2). Opener SQLite adalah infrastruktur, bukan domain/core. |
| DI via provider Riverpod saja | **Diterima** | Tanpa `get_it`; satu tempat wiring per fitur. |

## Hasil tiga grep verifikasi (dijalankan pada project akhir)

```powershell
# 1. Presentation steril dari data mentah
Get-ChildItem -Path lib\features\*\presentation -Recurse -Filter *.dart |
  Select-String -Pattern 'Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode'
# => 0 matches

# 2. Domain + core steril dari framework/package
Get-ChildItem -Path lib\features\*\domain, lib\core -Recurse -Filter *.dart |
  Select-String -Pattern "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase"
# => 0 matches

# 3. Static analysis + test
flutter analyze   # => No issues found!
flutter test      # => All tests passed! (23 tests)
```

Catatan: grep #2 memakai pola `import 'package:flutter` sehingga juga mencakup
`package:flutter_riverpod`. Karena `domain` dan `core` tidak mengimpor Riverpod,
hasilnya tetap nol.

## Pemeriksaan tambahan

```text
RepositoryImpl( pada presentation  -> hanya 3 file providers (wiring DI)
DateFormat|toIso8601String|jsonDecode pada presentation -> 0 matches
```

## Kesimpulan

Dependency rule terbukti: `presentation → domain ← data`. `domain` dan `core`
murni Dart; seluruh akses SQLite/Dio/SharedPreferences hanya di `data`
(dan `infrastructure` untuk pembuka database). Widget tidak menginstansiasi
repository; semua lewat provider.
