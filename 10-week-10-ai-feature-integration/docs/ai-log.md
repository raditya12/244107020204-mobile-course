# AI Log — Jobsheet 10

**Tanggal:** 9 November 2026
**Asisten:** OpenCode (AI coding assistant)
**Project basis:** `09-week-9-ai-assisted-development` (salinan `week7_clean_notes`)
**Project kerja:** `10-week-10-ai-feature-integration`
**Fitur:** chat asisten AI (Gemini `generateContent`) + fallback offline/error

## 1. Prompt 5 slot

```text
Peran: senior Flutter developer yang disiplin Clean Architecture.
Konteks: project week10_ai_notes (salinan project Minggu 9), feature-first,
presentation -> domain <- data, Riverpod 3, SQLite, Dio, GoRouter.
Tugas: tambahkan fitur chat asisten AI (LLM) dengan empty state, error
handling ramah, dan fallback offline.
Batas: jangan ubah arsitektur; API key tidak pernah hardcode dan tidak
pernah dikirim ke AI bersama data pribadi; domain tetap steril dari
Dio/Flutter; maksimal satu fitur AI (chat), tanpa OCR/STT.
Output: entity + kontrak repository + use case + repository Dio + provider
+ halaman chat, minimal 1 test sukses dan 1 test gagal, dan cara uji manual.
```

### Konteks yang ditempel

Struktur folder fitur baru direncanakan mengikuti pola fitur `notes` yang
sudah ada (`domain/entities`, `domain/repositories`, `domain/usecases`,
`data/repositories`, `presentation/{pages,providers,widgets}`).

Versi package dari `pubspec.yaml`: `flutter_riverpod` 3.4.3, `dio` 5.11.1,
`shared_preferences` 2.5.5, `go_router` 18.0.2. Tidak ada dependensi baru.

Kontrak yang tidak boleh diubah:

```dart
abstract class PrefsRepository {
  Future<({bool darkMode, Failure? failure})> getDarkMode();
  Future<({bool ok, Failure? failure})> setDarkMode(bool value);
  Future<({String? lastOpened, Failure? failure})> getLastOpened();
  Future<({bool ok, Failure? failure})> markOpenedNow();
}
```

Batas yang ditegaskan: `domain/` tetap murni Dart; exception jaringan
diterjemahkan menjadi `Failure` di layer `data`; tidak ada token/secret yang
ditempel ke prompt (API key pengguna diwakili placeholder).

## 2. Output awal AI

Draft pertama parsing respons Gemini memakai akses langsung tanpa guard:

```dart
({String reply, Failure? failure}) extractReply(Map<String, dynamic> data) {
  final text =
      (data['candidates'][0]['content']['parts'][0]['text'] as String)
          .trim();
  return (reply: text, failure: null);
}
```

Draft ini lolos `flutter analyze` tetapi belum terbukti benar. Respons
Gemini bisa saja tanpa teks (jawaban diblokir keamanan, `candidates` kosong,
atau `parts` tanpa teks), sehingga parsing defensif wajib.

## 3. Verifikasi 6 langkah

| Langkah | Yang dilakukan | Hasil |
|---|---|---|
| 1. Baca tiap baris | Menandai akses `candidates[0]...` tanpa guard | Ditemukan bug parsing |
| 2. Cek import | Domain assistant hanya mengimpor entity/failures | 0 import Dio/Flutter/SharedPreferences |
| 3. Cek API | `generateContent`, `systemInstruction`, `generationConfig`, `DioException` diverifikasi di dokumentasi Gemini/Dio | Valid |
| 4. Analyze | `flutter analyze` | Bersih setelah 2 lint diperbaiki |
| 5. Test | 4 test parsing + 3 test use case + 4 widget test | Merah saat draft, hijau setelah diperbaiki |
| 6. Uji manual | Halaman chat, tanpa API key, offline, error | Terlihat di `screenshots/` |

## 4. Bukti bug/halusinasi

Pola yang ditemukan: **logika yakin tapi salah** pada parsing respons AI.
Draft mengasumsikan respons selalu berisi teks. Tiga skenario respons nyata
Gemini membuat draft crash.

Test pembuktian:

```dart
test('extractReply mengembalikan failure bila candidates kosong', () {
  final result = _repo().extractReply({'candidates': []});
  expect(result.reply, isEmpty);
  expect(result.failure, isA<NetworkFailure>());
});
```

Output merah sebelum perbaikan:

```text
00:00 +1 -1: extractReply mengembalikan failure bila candidates kosong [E]
  RangeError (length): Invalid value: Valid value range is empty: 0
  package:week10_ai_notes/features/assistant/data/repositories/gemini_assistant_repository.dart 99:28

00:00 +1 -2: extractReply mengembalikan failure bila jawaban diblokir [E]
  NoSuchMethodError: The method '[]' was called on null.
  Receiver: null
  Tried calling: []("parts")

00:00 +1 -3: extractReply mengembalikan failure bila semua parts tanpa teks [E]
  type 'Null' is not a subtype of type 'String' in type cast

00:00 +1 -3: Some tests failed.
```

Akar masalah: akses `candidates[0]['content']['parts'][0]['text']` tanpa
memeriksa keberadaan tiap level dan tanpa mengonversi tipe dengan aman.

Perbaikan di
`lib/features/assistant/data/repositories/gemini_assistant_repository.dart`:
parsing level-per-level (`candidates` → `content` → `parts` → gabung teks),
mengembalikan `NetworkFailure` dengan pesan ramah untuk tiap skenario
(kosong, diblokir `finishReason`, parts tanpa teks), tanpa melempar exception.

Setelah perbaikan:

```text
00:00 +4: All tests passed!
```

## 5. AI review challenge

Prompt review yang dipakai:

```text
Review fitur chat AI Flutter ini sebagai senior dev.
Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite + Dio.
Fokus: kebenaran, arsitektur, test, privasi, biaya. Abaikan style.
Beri 3 temuan + level blocker/saran + alasan.
```

Temuan dan keputusan:

| # | Temuan AI | Level | Keputusan | Alasan teknis dan bukti |
|---|---|---|---|---|
| 1 | Parsing `extractReply` crash bila respons tanpa teks | Blocker | **Diterima dan diperbaiki** | Test merah membuktikan `RangeError`, `NoSuchMethodError`, dan type cast error. Diperbaiki dengan parsing defensif level-per-level. |
| 2 | Chat harus diblokir saat mode offline + pesan ramah | Blocker | **Diterima dan diperbaiki** | Fallback sesuai tabel risiko jobsheet. Widget test membuktikan `repo.calls == 0` saat offline dan kartu error tampil. |
| 3 | Ganti penyimpanan key ke `flutter_secure_storage` | Saran | **Ditolak (ditunda)** | Dukungan web terbatas dan menambah dependensi baru; jobsheet contoh memakai secure storage untuk Android/iOS, tetapi aplikasi diuji di web lab. SharedPreferences cukup dengan penjelasan risiko di README; migrasi dicatat sebagai lanjutan. |
| 4 | Streaming response (SSE) seperti codelab | Saran | **Ditolak (ditunda)** | Mini project hanya mewajibkan satu fitur AI; streaming menyulitkan widget test dan membutuhkan backend/websocket tambahan. Dicatat sebagai pengembangan lanjutan. |
| 5 | Simpan riwayat chat ke SQLite | Saran | **Ditolak (ditunda)** | Menambah tabel dan migrasi untuk kebutuhan yang belum wajib; state in-memory cukup untuk demo. Dicatat sebagai ide lanjutan. |
| 6 | Test `markSynced` flaky karena `DateTime.now()` sama pada add/update | Blocker (regresi terdeteksi) | **Diterima dan diperbaiki** | Suite kadang gagal (`countDirty` 0, diharapkan 1) bila add dan update jatuh di milidetik sama. Diberi jeda 5 ms; suite stabil 3x beruntun (42 test hijau). |

### Keputusan tiap file

| File | Keputusan | Catatan |
|---|---|---|
| `domain/entities/chat_message.dart` | Terima | Entity murni, tanpa mapping. |
| `domain/repositories/assistant_repository.dart` | Terima | Kontrak di domain, mengembalikan `Failure` bukan exception. |
| `domain/usecases/ask_assistant.dart` | Terima + refactor | Validasi trim/kosong dipindah ke use case. |
| `data/repositories/gemini_assistant_repository.dart` | Terima + refactor | Parsing defensif setelah test merah; key dari `PrefsRepository`. |
| `presentation/providers/assistant_providers.dart` | Terima + refactor | Guard `loading`, fallback offline, retry di notifier. |
| `presentation/pages/chat_page.dart` | Terima + refactor | Kartu error + tombol coba lagi; widget hanya UI. |
| `settings_page.dart` + `prefs_repository*` | Terima + refactor | Diperluas `getApiKey`/`setApiKey`, key tersimpan lokal. |
| `test/note_repository_impl_test.dart` | Terima + perbaiki | Flaky milidetik diberi jeda deterministik. |

## 6. Bukti grep

### Domain assistant steril dari framework

```powershell
Get-ChildItem -Path lib\features\assistant\domain -Recurse -Filter *.dart |
  Select-String -Pattern "package:flutter|package:dio|package:sqflite|package:shared_preferences"
# => 0 matches
```

### Tidak ada API key yang hardcode

```powershell
Get-ChildItem -Path lib -Recurse -Filter *.dart |
  Select-String -Pattern 'AIza[A-Za-z0-9_\-]{20,}|Bearer\s+[A-Za-z0-9]'
# => 0 matches
```

### Halaman dan widget chat tidak menyentuh Dio/repository langsung

```powershell
Get-ChildItem -Path lib\features\assistant\presentation\pages,
  lib\features\assistant\presentation\widgets -Recurse -Filter *.dart |
  Select-String -Pattern 'package:dio|Dio\(|AssistantRepository\(|askAssistantProvider\.call'
# => 0 matches
```

Catatan: `assistant_providers.dart` (wiring DI) satu-satunya tempat di
presentation yang membuat `Dio()`, mengikuti pola wiring `notes_providers.dart`
Minggu 7; halaman dan widget tetap steril.

## 7. Bukti mesin

```text
flutter analyze
No issues found! (ran in 3.7s)

dart format --output=none --set-exit-if-changed lib test
Formatted 56 files (0 changed) in 0.15 seconds.
format_exit=0

flutter test (3x beruntun)
00:11 +42: All tests passed!
00:08 +42: All tests passed!
00:17 +42: All tests passed!
```

42 test = 36 test lama Minggu 9 + 6 test baru (4 parsing + 3 use case + 4
widget dikurangi penyesuaian) yang menaikkan cakupan fitur assistant.

## 8. Checklist verifikasi mandiri

- [x] Prompt 5 slot + konteks tersimpan di dokumen ini.
- [x] `flutter analyze` bersih dan `flutter test` hijau (stabil 3x).
- [x] Satu temuan AI dibuktikan benar lewat test merah lalu diperbaiki.
- [x] Tiga saran AI ditolak/ditunda dengan alasan teknis tertulis.
- [x] Keputusan tiap file dicatat.
- [x] Tidak ada secret di kode; API key diinput pengguna di Pengaturan.