# Prompt review AI

Tanggal: 27 Oktober 2026.
Asisten: OpenCode.
Project yang direview: `07-week-7-clean-architecture`
(hasil refactor Clean Architecture Minggu 7).

## Prompt dari jobsheet

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

## Prompt yang benar-benar dipakai

```text
Review perubahan pada project Flutter Minggu 7 sebagai senior
Flutter developer.

Konteks:
- Feature-first Clean Architecture: presentation -> domain <- data.
- Riverpod 3 (Provider/FutureProvider/AsyncNotifier), GoRouter, SQLite
  (sqflite + sqflite_common_ffi), Dio untuk cache bacaan.
- Fitur: catatan offline (CRUD + dirty + sync), cache posts, preferensi tema.
- Domain dan core harus murni Dart (tanpa Flutter/Dio/SQLite).

Fokus review: kebenaran, arsitektur, dan test. Abaikan style yang sudah
ditangani dart format/CI.

Berikan maksimal 5 temuan teratas. Untuk setiap temuan sertakan:
1. level: blocker atau saran,
2. bukti file:line,
3. dampak bila dibiarkan,
4. usulan potongan kode perbaikan.

Tambahkan juga minimal satu saran yang mungkin over-engineering agar bisa
dinilai apakah layak diterapkan.
```

Output awal AI disimpan di [`02-output-ai.md`](02-output-ai.md).
Verifikasi, tabel usulan-vs-keputusan, dan bukti grep/test disimpan di
[`ai-review-vs-keputusan.md`](ai-review-vs-keputusan.md).