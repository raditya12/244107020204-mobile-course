# 01 — Prompt yang digunakan

## Prompt implementasi awal (verbatim)

```text
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

## Prompt audit dan dokumentasi (verbatim)

```text
AI Verification Checklist
Sebelum kode AI diterima, verifikasi hal berikut dan catat temuan Anda di README:

Apakah state diubah secara immutable (tidak ada state.add() atau mutasi list langsung)?
Apakah ref.watch hanya dipakai di dalam build, dan ref.read di callback?
Apakah ketiga state AsyncValue benar-benar ditangani (bukan hanya success)?
Apakah provider dideklarasikan dengan tipe eksplisit dan tidak duplikat dengan provider lain?
Apakah kode AI memakai API Riverpod versi lama (StateProvider antipattern, StateNotifierProvider usang, atau Consumer bertingkat yang tidak perlu)? Perbaiki ke pola Notifier/ConsumerWidget.
Jalankan flutter analyze dan flutter test, apakah hasil AI lolos tanpa warning?
Tanggung jawab teknis: simpan prompt yang digunakan, output awal AI, perbaikan yang Anda lakukan, dan hasil testing pada folder docs/ tugas minggu ini. Saat demo, Anda harus mampu menjelaskan setiap baris kode hasil AI. tulis pada readme dan tandai ini sebagai nomer 5 AI challange catat semua yang dipertanyakan step by stepnya
```

## Konteks pelaksanaan

AI mengimplementasikan fitur pada `week3_todo` karena proyek tersebut sudah menggunakan Riverpod. Audit dilakukan pada hasil implementasi awal yang sudah selesai. Seluruh catatan disimpan dalam folder tugas minggu 3, `03-week-3-navigation-state-management/docs/ai-challenge/`.
