# AI Prompt Challenge

Tanggal penyusunan: 15 Oktober 2026. Asisten: OpenCode.
Project yang direfactor: `week5_offline_notes` (hasil Minggu 5) → `week7_clean_notes`.

## Prompt asli dari jobsheet (untuk `campus_notify`)

```text
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
   (presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

## Prompt yang benar-benar dipakai (disesuaikan ke project nyata)

```text
Project Flutter saya: week5_offline_notes (Offline Notes).
Fitur: catatan lokal SQLite (CRUD + dirty flag + sinkronisasi simulasi),
cache bacaan API (Dio + SQLite cache-first), dan preferensi tema
(SharedPreferences).
Kondisi kini: layer-first lib/{data, local, pages, widgets}.
- Entity Note bercampur mapping toMap/fromMap (lib/local/note.dart).
- Interface dan implementasi repository ada di satu kelas
  (lib/data/repositories/note_repository.dart).
- Model Post dan PostRepository bercampur (lib/data/repositories/post_repository.dart).
- Logika sinkronisasi ada di lib/data/sync.dart (bukan domain).
- Provider DI didefinisikan di lib/data/providers.dart dan bahkan di dalam
  lib/pages/settings_page.dart.
- Widget memformat tanggal mentah (toLocal().toString().split('.')).
Tugas:
1. Usulkan struktur feature-first Clean Architecture (presentation/domain/data)
   untuk fitur notes, posts, dan settings.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
   dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

Jawaban awal AI disimpan di [`02-output-ai.md`](02-output-ai.md). Verifikasi,
tabel usulan-vs-keputusan, dan alasan teknis disimpan di
[`03-verifikasi-ai.md`](03-verifikasi-ai.md).
